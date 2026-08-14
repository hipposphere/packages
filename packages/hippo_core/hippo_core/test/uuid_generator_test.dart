import 'package:hippo_core/hippo_core.dart';
import 'package:test/test.dart';

void main() {
  test('RandomUuidGenerator produces distinct version 4 UUIDs', () {
    const generator = RandomUuidGenerator();

    final first = generator.generateV4();
    final second = generator.generateV4();

    expect(
      first,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
    );
    expect(
      second,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
    );
    expect(second, isNot(first));
  });
}
