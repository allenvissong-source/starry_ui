/// Compact count formatting for metric affordances (like counts, comment
/// counts, follower counts …).
///
/// [compact] collapses large integers into a short "万" (`w`) form so a metric
/// button stays narrow: counts `>= 10000` render as `Nw` (one decimal below
/// ten-thousands, integer at or above), and everything below `10000` renders
/// as its plain decimal string. The `w` (万) grouping is the zh-CN default;
/// callers that need another locale's grouping pass their own formatter to the
/// consuming widget instead of mutating this one.
class StarryCountFormatter {
  const StarryCountFormatter._();

  /// Format [count] into its compact display string.
  ///
  /// - `count < 10000` → the plain decimal string (e.g. `9999`).
  /// - `count >= 10000` → `<value>w`, where `value = count / 10000` rendered
  ///   with 1 decimal while `< 10` (e.g. `1.2w`) and as an integer once
  ///   `>= 10` (e.g. `12w`).
  ///
  /// Negative counts are clamped to `0` — a metric count is never negative and
  /// a stray negative should not leak a minus sign into the UI.
  static String compact(int count) {
    if (count <= 0) return '0';
    if (count >= 10000) {
      final double value = count / 10000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}w';
    }
    return count.toString();
  }
}
