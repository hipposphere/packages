/*
// ---------------------------------------------------------------------------
// Copyright (c) 2026 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

// test_reflective_loader discovers test methods by their test_ prefix.
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:hippo_analysis_plugin/src/prefer_dot_shorthands.dart';
import 'package:hippo_analysis_plugin/src/use_dot_shorthand.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferDotShorthandsTest);
  });
}

@reflectiveTest
class PreferDotShorthandsTest extends AnalysisRuleTest {
  @override
  bool get dumpAstOnFailures => false;

  @override
  void setUp() {
    rule = PreferDotShorthands();
    super.setUp();
  }

  Future<void> test_enumArgument() => _assertFix(
    '''
enum Status { active }
void accept(Status status) {}
void f() => accept(Status.active);
''',
    'Status.active',
    '.active',
  );

  Future<void> test_namedArgument() => _assertFix(
    '''
enum Status { active }
void accept({required Status status}) {}
void f() => accept(status: Status.active);
''',
    'Status.active',
    '.active',
  );

  Future<void> test_nullableVariable() => _assertFix(
    '''
enum Status { active }
Status? status = Status.active;
''',
    'Status.active',
    '.active',
  );

  Future<void> test_equality() => _assertFix(
    '''
enum Status { active }
bool f(Status status) => status == Status.active;
''',
    'Status.active',
    '.active',
  );

  Future<void> test_assignment() => _assertFix(
    '''
enum Status { active }
void f(Status status) { status = Status.active; }
''',
    'Status.active',
    '.active',
  );

  Future<void> test_defaultParameter() => _assertFix(
    '''
enum Status { active }
void f({Status status = Status.active}) {}
''',
    'Status.active',
    '.active',
  );

  Future<void> test_return() => _assertFix(
    '''
enum Status { active }
Status f() { return Status.active; }
''',
    'Status.active',
    '.active',
  );

  Future<void> test_asyncReturn() => _assertFix(
    '''
enum Status { active }
Future<Status> f() async => Status.active;
''',
    'Status.active',
    '.active',
  );

  Future<void> test_callbackReturn() => _assertFix(
    '''
enum Status { active }
void accept(Status Function() callback) {}
void f() => accept(() => Status.active);
''',
    'Status.active',
    '.active',
  );

  Future<void> test_futureOr() => _assertFix(
    '''
import 'dart:async';
enum Status { active }
void accept(FutureOr<Status> status) {}
void f() => accept(Status.active);
''',
    'Status.active',
    '.active',
  );

  Future<void> test_conditional() => _assertFix(
    '''
enum Status { active }
Status f(bool condition, Status fallback) => condition ? Status.active : fallback;
''',
    'Status.active',
    '.active',
  );

  Future<void> test_explicitListElement() => _assertFix(
    '''
enum Status { active }
final statuses = <Status>[Status.active];
''',
    'Status.active',
    '.active',
  );

  Future<void> test_explicitMapValue() => _assertFix(
    '''
enum Status { active }
final statuses = <String, Status>{'key': Status.active};
''',
    'Status.active',
    '.active',
  );

  Future<void> test_namedConstructor() => _assertFix(
    '''
class Point { Point.origin(); }
Point f() => Point.origin();
''',
    'Point.origin()',
    '.origin()',
  );

  Future<void> test_unnamedConstructor() => _assertFix(
    '''
class Point { Point(); }
Point f() => Point();
''',
    'Point()',
    '.new()',
  );

  Future<void> test_constConstructor() => _assertFix(
    '''
class Point { const Point.origin(); }
Point f() => const Point.origin();
''',
    'const Point.origin()',
    'const .origin()',
  );

  Future<void> test_staticField() => _assertFix(
    '''
class Point {
  const Point();
  static const zero = Point();
}
Point f() => Point.zero;
''',
    'Point.zero',
    '.zero',
  );

  Future<void> test_staticGetter() => _assertFix(
    '''
class Point {
  static Point get zero => throw 0;
}
Point f() => Point.zero;
''',
    'Point.zero',
    '.zero',
  );

  Future<void> test_staticMethod() => _assertFix(
    '''
class Point {
  static Point origin() => throw 0;
}
Point f() => Point.origin();
''',
    'Point.origin()',
    '.origin()',
  );

  Future<void> test_importPrefix() async {
    newFile('$testPackageLibPath/model.dart', 'enum Status { active }');
    await _assertFix(
      '''
import 'model.dart' as model;
model.Status f() => model.Status.active;
''',
      'model.Status.active',
      '.active',
    );
  }

  Future<void> test_constructorImportPrefix() async {
    newFile('$testPackageLibPath/model.dart', 'class Point { Point.origin(); }');
    await _assertFix(
      '''
import 'model.dart' as model;
model.Point f() => model.Point.origin();
''',
      'model.Point.origin()',
      '.origin()',
    );
  }

  Future<void> test_preservesComment() => _assertFix(
    '''
enum Status { active }
Status f() => Status /* keep */ .active;
''',
    'Status /* keep */ .active',
    ' /* keep */ .active',
  );

  Future<void> test_inferredVariables() => assertNoDiagnostics('''
enum Status { active }
final status = Status.active;
final statuses = [Status.active];
Status inferredReturn() => .active;
''');

  Future<void> test_typedefPrivateConstructorAcrossLibraries() async {
    newFile('$testPackageLibPath/model.dart', 'class _Body { _Body(); } typedef Body = _Body;');
    await assertNoDiagnostics('''
import 'model.dart';
Body createBody() => Body();
void accept(Body value) {}
void f() => accept(Body());
''');
  }

  Future<void> test_typedefPublicConstructor() => _assertFix(
    '''
class Body { Body(); }
typedef PublicBody = Body;
PublicBody createBody() => PublicBody();
''',
    'PublicBody()',
    '.new()',
  );

  Future<void> test_typedefPrivateConstructorSameLibrary() => _assertFix(
    '''
class _Body { _Body(); }
typedef Body = _Body;
Body createBody() => Body();
''',
    'Body()',
    '.new()',
  );

  Future<void> test_genericConstructors() => assertNoDiagnostics('''
class Box<T> { Box.value(T value); }
Box<int> explicit() => Box<int>.value(1);
Box<int> inferred() => Box.value(1);
''');

  Future<void> test_genericArgumentInference() => assertNoDiagnostics('''
enum Status { active }
T identity<T>(T value) => value;
final status = identity(Status.active);
''');

  Future<void> test_incompatibleContextOwner() => assertNoDiagnostics('''
enum Status { active }
class Factory { static Status get active => throw 0; }
Object broadContext() => Status.active;
Status differentOwner() => Factory.active;
''');

  Future<void> test_subtypeConstructor() => assertNoDiagnostics('''
class Base {}
class Derived extends Base { Derived(); }
Base f() => Derived();
''');

  Future<void> test_inferredReturn() => assertNoDiagnostics('''
enum Status { active }
f() => Status.active;
''');

  Future<void> test_instanceMembers() => assertNoDiagnostics('''
class Point { Point get self => this; Point copy() => this; }
Point f(Point point) => point.self;
Point g(Point point) => point.copy();
''');

  Future<void> test_olderLanguageVersion() => assertNoDiagnostics('''
// @dart=3.9
enum Status { active }
Status f() => Status.active;
''');

  Future<void> _assertFix(String source, String expression, String replacement) async {
    final offset = source.lastIndexOf(expression);
    expect(offset, isNonNegative);
    await assertDiagnostics(source, [lint(offset, expression.length)]);
    final diagnostic = result.diagnostics.singleWhere(
      (diagnostic) => diagnostic.diagnosticCode == PreferDotShorthands.code,
    );
    final library = await result.session.getResolvedLibraryByElement(
      result.libraryElement,
    ) as ResolvedLibraryResult;
    final producer = UseDotShorthand(
      context: .createResolved(
        libraryResult: library,
        unitResult: result,
        diagnostic: diagnostic,
        selectionOffset: offset,
        selectionLength: expression.length,
      ),
    );
    final builder = ChangeBuilder(session: result.session);
    await producer.compute(builder);
    final changes = builder.sourceChange.getFileEdit(testFilePath)!.edits;
    final fixed = SourceEdit.applySequence(source, changes);
    expect(fixed, source.replaceRange(offset, offset + expression.length, replacement));
    newFile(testFilePath, fixed);
    contextFor2(testFile).changeFile(testFilePath);
    await assertNoDiagnostics(fixed);
  }
}
