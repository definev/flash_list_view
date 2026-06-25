/// Binary Indexed Tree (Fenwick tree) over per-index item heights.
///
/// Provides O(log n) prefix sums and point updates with an O(n log n) rebuild.
/// The rebuild only runs on list invalidation or child-count changes, so the
/// per-frame scroll path never pays for it.
///
/// This type is part of the package implementation; it is exposed (rather than
/// being a private class) only so it can be unit-tested directly.
class CumulativeHeightTree {
  List<double> _values = const <double>[];
  // 1-based Fenwick storage; index 0 is unused.
  List<double> _tree = const <double>[];
  int _length = 0;

  /// Number of tracked items.
  int get length => _length;

  /// Sum of every tracked item height.
  double get total => prefixSum(_length);

  /// Rebuilds the tree for [count] items, reading each height from [heightAt].
  void rebuild(int count, double Function(int index) heightAt) {
    _length = count < 0 ? 0 : count;
    _values = List<double>.filled(_length, 0.0);
    _tree = List<double>.filled(_length + 1, 0.0);
    for (var i = 0; i < _length; i++) {
      final h = heightAt(i);
      _values[i] = h;
      var j = i + 1;
      while (j <= _length) {
        _tree[j] += h;
        j += j & -j;
      }
    }
  }

  /// Sum of heights in the half-open range `[0, index)`.
  ///
  /// [index] is clamped to `[0, length]`.
  double prefixSum(int index) {
    var i = index;
    if (i <= 0) {
      return 0.0;
    }
    if (i > _length) {
      i = _length;
    }
    var sum = 0.0;
    while (i > 0) {
      sum += _tree[i];
      i -= i & -i;
    }
    return sum;
  }

  /// Sets the height at [index] to [newValue]. No-op for out-of-range indices.
  void update(int index, double newValue) {
    if (index < 0 || index >= _length) {
      return;
    }
    final delta = newValue - _values[index];
    if (delta == 0.0) {
      return;
    }
    _values[index] = newValue;
    var i = index + 1;
    while (i <= _length) {
      _tree[i] += delta;
      i += i & -i;
    }
  }
}
