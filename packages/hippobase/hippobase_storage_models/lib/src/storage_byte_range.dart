/// Provider-neutral request for one inclusive byte range of a stored object.
final class StorageByteRange {
  const StorageByteRange.closed(int start, int end)
    : start = start,
      end = end,
      suffixLength = null,
      assert(start >= 0),
      assert(end >= start);

  const StorageByteRange.from(int start)
    : start = start,
      end = null,
      suffixLength = null,
      assert(start >= 0);

  const StorageByteRange.suffix(int suffixLength)
    : start = null,
      end = null,
      suffixLength = suffixLength,
      assert(suffixLength > 0);

  final int? start;
  final int? end;
  final int? suffixLength;
}
