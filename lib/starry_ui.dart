/// starry_ui — Starry design-system public API.
///
/// Only public-stable symbols are exported here. Implementation under
/// `lib/src/` is private and must NOT be imported directly by consumers.
///
/// A symbol appears in this barrel only once it reaches *public stable*.
library;

// Theme & design tokens.
export 'src/theme/starry_tokens.dart';
export 'src/theme/app_theme.dart';

// Buttons.
export 'src/buttons/starry_icon_button.dart';
export 'src/buttons/starry_text_button.dart';
export 'src/buttons/starry_button.dart';

// Containers / surfaces.
export 'src/components/starry_card.dart';
export 'src/components/starry_expandable_card.dart';
export 'src/components/starry_control_shell.dart';

// Feedback.
export 'src/feedback/starry_message_list.dart';
export 'src/feedback/starry_empty_state.dart';
export 'src/feedback/starry_loading_indicator.dart';
export 'src/feedback/starry_looping_animations.dart';

// Inputs.
export 'src/inputs/starry_search_input.dart';
export 'src/inputs/starry_switch.dart';
export 'src/inputs/starry_text_field.dart';
export 'src/inputs/starry_textarea.dart';

// Layout.
export 'src/layout/starry_page_wrapper.dart';

// Overlays.
export 'src/overlays/starry_overlay_background.dart';

// Tags.
export 'src/tags/starry_badge.dart';
export 'src/tags/starry_chip.dart';
export 'src/tags/starry_tag.dart';
// Text.
export 'src/text/starry_emoji_text.dart';
