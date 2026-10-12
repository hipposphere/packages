import 'package:jaspr/client.dart';
import 'package:web/web.dart' as web;

import 'src/report_model.dart';
import 'src/report_viewer.dart';
import 'src/ui.dart';

void main() {
  Jaspr.initializeApp();
  try {
    final source = web.document.getElementById('hippo-report-data')?.textContent;
    if (source == null) throw const FormatException('Report data is missing');
    runApp(ReportViewer(TestRun.fromJson(source)), attachTo: '#app');
  } catch (error) {
    runApp(
      empty(
        'Unable to open this report',
        '$error. The original results.json and runner.log remain available beside this file.',
      ),
      attachTo: '#app',
    );
  }
}
