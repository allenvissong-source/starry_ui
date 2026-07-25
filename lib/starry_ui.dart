/// starry_ui — Starry design-system public API.
///
/// Only public-stable symbols are exported here. Implementation under
/// `lib/src/` and any component parked in `lib/src/_migrating/` is private
/// and must NOT be imported directly by consumers.
///
/// Maturity state machine: `_migrating -> internal stable -> public stable`.
/// A symbol appears in this barrel only once it reaches *public stable*.
library;

// Theme & design tokens.
export 'src/theme/starry_tokens.dart';
export 'src/theme/app_theme.dart';

// Components (public stable).
export 'src/components/starry_button.dart';
export 'src/components/starry_card.dart';
export 'src/components/starry_input.dart';
export 'src/components/starry_switch.dart';
export 'src/components/starry_tag.dart';
export 'src/components/starry_textarea.dart';
