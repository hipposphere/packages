/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// The minimal qualifier edit shared by diagnostics and their quick fix.
class ShorthandEdit {
  ShorthandEdit({required this.target, required this.owner, required this.replacement});

  final AstNode target;
  final InterfaceElement owner;
  final String replacement;
}

ShorthandEdit? shorthandEdit(Expression expression) {
  final AstNode target;
  final InterfaceElement owner;
  final String replacement;
  if (expression is InstanceCreationExpression) {
    final constructor = expression.constructorName;
    final element = constructor.element;
    if (element == null ||
        element.enclosingElement.typeParameters.isNotEmpty ||
        constructor.type.typeArguments != null ||
        expression.keyword?.lexeme == 'new') {
      return null;
    }
    final library = expression.thisOrAncestorOfType<CompilationUnit>()?.declaredFragment?.element;
    if (element.enclosingElement.isPrivate && element.enclosingElement.library != library) {
      return null;
    }
    target = constructor.type;
    owner = element.enclosingElement;
    replacement = constructor.name == null ? '.new' : '';
  } else {
    final Expression? qualifier;
    final Element? member;
    if (expression is PrefixedIdentifier) {
      qualifier = expression.prefix;
      member = expression.identifier.element;
    } else if (expression is PropertyAccess && !expression.isNullAware) {
      qualifier = expression.target;
      member = expression.propertyName.element;
    } else if (expression is MethodInvocation &&
        !expression.isNullAware &&
        !expression.isCascaded &&
        expression.typeArguments == null) {
      qualifier = expression.target;
      member = expression.methodName.element;
    } else {
      return null;
    }
    final element = switch (qualifier) {
      Identifier(:final element) => element,
      _ => null,
    };
    if (element is! InterfaceElement || member == null) return null;
    final isStatic = switch (member) {
      ExecutableElement(:final isStatic) => isStatic,
      FieldElement(:final isStatic) => isStatic,
      _ => false,
    };
    if (!isStatic || member.enclosingElement != element) return null;
    target = qualifier!;
    owner = element;
    replacement = '';
  }
  // Removing an imported qualifier must not discard comments embedded in it.
  var token = target.beginToken.next;
  while (token != null && token.offset < target.end) {
    if (token.precedingComments != null) return null;
    token = token.next;
  }
  return .new(target: target, owner: owner, replacement: replacement);
}
