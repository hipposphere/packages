/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'shorthand_edit.dart';

class PreferDotShorthands extends AnalysisRule {
  PreferDotShorthands()
    : super(
        name: 'prefer_dot_shorthands',
        description: 'Prefer dot shorthands when the surrounding type identifies the member.',
      );

  static const code = LintCode(
    'prefer_dot_shorthands',
    'Use a dot shorthand for this contextually typed expression.',
    correctionMessage: 'Remove the redundant type qualifier.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    if (!context.isFeatureEnabled(.dot_shorthands)) return;
    final visitor = _Visitor(rule: this, context: context);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
    registry.addPrefixedIdentifier(this, visitor);
    registry.addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor({required this.rule, required this.context});

  final PreferDotShorthands rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) => _check(node);

  @override
  void visitMethodInvocation(MethodInvocation node) => _check(node);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) => _check(node);

  @override
  void visitPropertyAccess(PropertyAccess node) => _check(node);

  void _check(Expression node) {
    final edit = shorthandEdit(node);
    if (edit == null) return;
    var expected = _contextType(node);
    if (expected == null) return;
    if (expected.isDartAsyncFutureOr) expected = context.typeSystem.flatten(expected);
    if (expected is! InterfaceType || expected.element != edit.owner) return;
    // A constructor must retain its inferred generic arguments as well as its class.
    if (node is InstanceCreationExpression &&
        context.typeSystem.promoteToNonNull(expected) != node.staticType) {
      return;
    }
    rule.reportAtNode(node);
  }

  DartType? _contextType(Expression expression) {
    final parent = expression.parent;
    // Equality has a language-defined context from its left operand, rather
    // than the broad Object parameter of operator ==.
    if (parent is BinaryExpression &&
        (parent.operator.lexeme == '==' || parent.operator.lexeme == '!=') &&
        parent.rightOperand.offset == expression.offset) {
      return parent.leftOperand.staticType;
    }
    if (parent is AssignmentExpression &&
        parent.operator.lexeme == '=' &&
        parent.rightHandSide.offset == expression.offset) {
      return parent.writeType;
    }
    // Use the declaration's parameter type, not an inferred substitution which
    // might itself have been inferred from the expression being shortened.
    final parameter = expression.correspondingParameter;
    if (parameter != null) return parameter.baseElement.type;
    if (parent is ParenthesizedExpression) return _contextType(parent);
    if (parent is NamedArgument) return parent.correspondingParameter?.baseElement.type;
    if (parent is ConditionalExpression &&
        (parent.thenExpression == expression || parent.elseExpression == expression)) {
      return _contextType(parent);
    }
    if (parent is VariableDeclaration && parent.initializer == expression) {
      final declarations = parent.parent;
      if (declarations is VariableDeclarationList) return declarations.type?.type;
    }
    if (parent is FormalParameterDefaultClause && parent.parent is FormalParameter) {
      return (parent.parent! as FormalParameter).declaredFragment?.element.type;
    }
    if (parent is ReturnStatement) {
      final body = parent.thisOrAncestorOfType<FunctionBody>();
      return body == null ? null : _returnType(body);
    }
    if (parent is ExpressionFunctionBody) return _returnType(parent);
    // Explicit collection type arguments are independent of their elements.
    if (parent is ListLiteral) return parent.typeArguments?.arguments.first.type;
    if (parent is SetOrMapLiteral && !parent.isMap) {
      return parent.typeArguments?.arguments.first.type;
    }
    if (parent is MapLiteralEntry) {
      final literal = parent.parent;
      if (literal is SetOrMapLiteral && literal.typeArguments != null) {
        final index = parent.key == expression ? 0 : 1;
        return literal.typeArguments!.arguments[index].type;
      }
    }
    return null;
  }

  DartType? _returnType(FunctionBody body) {
    final function = body.parent;
    DartType? result;
    if (function is MethodDeclaration) {
      result = function.returnType?.type;
    } else if (function is FunctionExpression) {
      final declaration = function.parent;
      if (declaration is FunctionDeclaration) {
        result = declaration.returnType?.type;
      } else {
        final signature = _contextType(function);
        if (signature is FunctionType) result = signature.returnType;
      }
    }
    if (result != null && body.isAsynchronous) return context.typeSystem.flatten(result);
    return result;
  }
}
