/// Count formatting helpers for metric affordances (like counts, comment
/// counts, follower counts …).
///
/// Two formatters cover two different display needs, and both are kept on
/// purpose:
///
/// - [compact] collapses large integers into a short "万" (`w`) form so a
///   metric button stays narrow: counts `>= 10000` render as `Nw` (one
///   decimal below ten-thousands, integer at or above), and everything below
///   `10000` renders as its plain decimal string. This is the default for
///   space-constrained surfaces (feed cards, metric chips). The `w` (万)
///   grouping is the zh-CN default; callers that need another locale's
///   grouping pass their own formatter to the consuming widget instead of
///   mutating this one.
/// - [grouped] preserves the *exact* integer with thousands separators
///   (`1234` → `"1,234"`, `1234567` → `"1,234,567"`). Use it where the exact
///   number matters and width is not a constraint (revision history, exact
///   totals, lists …).
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

  /// Format [count] with thousands separators, preserving the exact value:
  /// `1234` → `"1,234"`, `1234567` → `"1,234,567"`, `0` → `"0"`.
  ///
  /// Unlike [compact] (which trades precision for narrowness on feed-card
  /// metrics), [grouped] keeps the full number comma-grouped for contexts
  /// where exactness matters (revision history, exact totals, …).
  ///
  /// Negative counts are clamped to `0`, matching [compact].
  static String grouped(int count) {
    if (count <= 0) return '0';
    final digits = count.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
