import 'package:hippo_core/hippo_core.dart';
import 'package:test/test.dart';

void main() {
  test('classifies web and native runtime platforms', () {
    expect(RuntimePlatform.web.isWeb, isTrue);
    expect(RuntimePlatform.web.isNative, isFalse);
    expect(RuntimePlatform.android.isWeb, isFalse);
    expect(RuntimePlatform.android.isNative, isTrue);
  });

  test('classifies native desktop runtime platforms', () {
    expect(RuntimePlatform.macOS.isDesktop, isTrue);
    expect(RuntimePlatform.windows.isDesktop, isTrue);
    expect(RuntimePlatform.linux.isDesktop, isTrue);
    expect(RuntimePlatform.web.isDesktop, isFalse);
    expect(RuntimePlatform.android.isDesktop, isFalse);
  });

  test('classifies native mobile runtime platforms', () {
    expect(RuntimePlatform.android.isMobile, isTrue);
    expect(RuntimePlatform.iOS.isMobile, isTrue);
    expect(RuntimePlatform.web.isMobile, isFalse);
    expect(RuntimePlatform.macOS.isMobile, isFalse);
  });
}
