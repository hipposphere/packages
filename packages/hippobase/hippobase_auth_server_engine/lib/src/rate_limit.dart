import 'dart:async';

abstract interface class HippobaseAuthRateLimiter {
  Future<bool> allow(String key, {required int limit, required Duration window});
}

final class HippobaseAuthMemoryRateLimiter implements HippobaseAuthRateLimiter {
  final Map<String, _RateBucket> _buckets = <String, _RateBucket>{};

  @override
  Future<bool> allow(String key, {required int limit, required Duration window}) async {
    final now = DateTime.now().toUtc();
    final existing = _buckets[key];
    if (existing == null || !existing.startedAt.add(window).isAfter(now)) {
      _buckets[key] = _RateBucket(now, 1);
      _prune(now);
      return true;
    }
    if (existing.count >= limit) return false;
    existing.count++;
    return true;
  }

  void _prune(DateTime now) {
    if (_buckets.length < 2048) return;
    _buckets.removeWhere(
      (_, bucket) => now.difference(bucket.startedAt) > const Duration(hours: 1),
    );
  }
}

final class _RateBucket {
  _RateBucket(this.startedAt, this.count);

  final DateTime startedAt;
  int count;
}
