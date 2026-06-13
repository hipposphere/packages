enum HippoColorMode { auto, always, never }

enum HippoStatus { ok, warn, fail, skip, run, info }

final class HippoTheme {
  const HippoTheme({required this.enabled});

  final bool enabled;

  String cyan(String text) => _wrap('36', text);
  String green(String text) => _wrap('32', text);
  String amber(String text) => _wrap('33', text);
  String red(String text) => _wrap('31', text);
  String gray(String text) => _wrap('90', text);
  String bold(String text) => _wrap('1', text);

  String statusLabel(HippoStatus status) {
    return switch (status) {
      HippoStatus.ok => green('OK'),
      HippoStatus.warn => amber('WARN'),
      HippoStatus.fail => red('FAIL'),
      HippoStatus.skip => gray('SKIP'),
      HippoStatus.run => cyan('RUN'),
      HippoStatus.info => cyan('INFO'),
    };
  }

  String _wrap(String code, String text) {
    if (!enabled || text.isEmpty) {
      return text;
    }
    return '\x1B[${code}m$text\x1B[0m';
  }
}
