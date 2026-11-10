import 'package:observability_wire/observability_wire.dart';
import 'package:test/test.dart';

void main() {
  group('planning (from the Dicto server)', () {
    test('step defaults to range/1000, is raised to fit max_points and is at least 1 s', () {
      const day = Duration(days: 1);
      expect(planStepSeconds(range: day, maxPoints: 2000), 87);
      expect(planStepSeconds(range: day, maxPoints: 2000, requested: 15), 44);
      expect(planStepSeconds(range: day, maxPoints: 11000, requested: 15), 15);
      expect(planStepSeconds(range: day, maxPoints: 2000, requested: 600), 600);
      expect(planStepSeconds(range: const .new(minutes: 5), maxPoints: 2000), 1);
      expect(planStepSeconds(range: const .new(minutes: 5), maxPoints: 2000, requested: 0.2), 1);
      expect(planStepSeconds(range: const .new(days: 400), maxPoints: 2000, requested: -1), 34560);
      for (final range in [const Duration(hours: 1), day, const Duration(days: 30)]) {
        final step = planStepSeconds(range: range, maxPoints: 500, requested: 1);
        expect(range.inSeconds / step, lessThanOrEqualTo(500));
      }
    });

    test('Grafana macros expand from the planned step and range', () {
      const range = Duration(hours: 6);
      String expand(String expression, {int step = 30}) =>
          expandMacros(expression, stepSeconds: step, range: range);
      expect(expand(r'rate(x[$__rate_interval])'), 'rate(x[60s])');
      expect(expand(r'rate(x[$__rate_interval])', step: 120), 'rate(x[135s])');
      expect(
        expand(r'avg_over_time(x[$__interval]) / $__interval_ms'),
        'avg_over_time(x[30s]) / 30000',
      );
      expect(
        expand(r'increase(x[$__range]) $__range_s $__range_ms'),
        'increase(x[21600s]) 21600 21600000',
      );
      expect(expand(r'sum(rate(x[${__interval}])) ${__range_s}'), 'sum(rate(x[30s])) 21600');
      expect(expand(r'$__intervalx $route'), r'$__intervalx $route');
    });

  });
}
