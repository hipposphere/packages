final class HippoTable {
  const HippoTable({required this.headers, required this.rows, this.maxWidth = 100});

  final List<String> headers;
  final List<List<String>> rows;
  final int maxWidth;

  String render() {
    if (headers.isEmpty) {
      return '';
    }

    final widths = <int>[
      for (var column = 0; column < headers.length; column++)
        _columnWidth(column).clamp(3, maxWidth),
    ];
    final buffer = StringBuffer();
    _writeRow(buffer, headers, widths);
    for (final row in rows) {
      _writeRow(buffer, row, widths);
    }
    return buffer.toString();
  }

  int _columnWidth(int column) {
    var width = headers[column].length;
    for (final row in rows) {
      if (column < row.length && row[column].length > width) {
        width = row[column].length;
      }
    }
    return width;
  }

  void _writeRow(StringBuffer buffer, List<String> row, List<int> widths) {
    for (var column = 0; column < widths.length; column++) {
      if (column > 0) {
        buffer.write('  ');
      }
      final value = column < row.length ? row[column] : '';
      buffer.write(_fit(value, widths[column]).padRight(widths[column]));
    }
    buffer.writeln();
  }

  String _fit(String value, int width) {
    if (value.length <= width) {
      return value;
    }
    if (width <= 1) {
      return value.substring(0, width);
    }
    if (width <= 3) {
      return value.substring(0, width);
    }
    return '${value.substring(0, width - 3)}...';
  }
}
