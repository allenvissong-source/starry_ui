/// starry_ui — Starry design-system public API.
///
/// Only public-stable symbols are exported here. Implementation under
/// `lib/src/` is private and must NOT be imported directly by consumers.
///
/// A symbol appears in this barrel only once it reaches *public stable*.
library;

// Theme & design tokens.
export 'src/theme/starry_tokens.dart';
export 'src/theme/starry_application_tokens.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/starry_responsive.dart';

// Buttons.
export 'src/buttons/starry_icon_button.dart';
export 'src/buttons/starry_text_button.dart';
export 'src/buttons/starry_button.dart';
export 'src/buttons/starry_toggle_icon_button.dart';
export 'src/buttons/starry_metric_button.dart';
export 'src/buttons/starry_primary_action_button.dart';

// Foundations.
export 'src/foundations/starry_count_formatter.dart';

// Media.
export 'src/media/starry_avatar.dart';
export 'src/media/starry_media_stage.dart';
export 'src/media/starry_reference_card.dart';

// Containers / surfaces.
export 'src/components/starry_action_option_card.dart';
export 'src/components/starry_card.dart';
export 'src/components/starry_expandable_card.dart';
export 'src/components/starry_masonry_card.dart';
export 'src/components/starry_control_shell.dart';
export 'src/components/starry_surface.dart';

// Feedback.
export 'src/feedback/starry_message_list.dart';
export 'src/feedback/starry_empty_state.dart';
export 'src/feedback/starry_loading_indicator.dart';
export 'src/feedback/starry_skeleton_or_content.dart';
export 'src/feedback/starry_sliver_skeleton_or_content.dart';

// Inputs.
export 'src/inputs/starry_search_input.dart';
export 'src/inputs/starry_dropdown.dart';
export 'src/inputs/starry_slider.dart';
export 'src/inputs/starry_switch.dart';
export 'src/inputs/starry_text_field.dart';
export 'src/inputs/starry_textarea.dart';

// Interactions.
export 'src/interactions/starry_press_scale.dart';
export 'src/interactions/starry_selected_highlight.dart';
export 'src/interactions/starry_slidable_drawer.dart';
export 'src/interactions/starry_swipe_action.dart';

// Layout.
export 'src/layout/masonry_feed_metrics.dart';
export 'src/layout/sliver_masonry_feed.dart';
export 'src/layout/starry_ambient_background.dart';
export 'src/layout/starry_desktop_window_frame.dart';
export 'src/layout/starry_glass_panel.dart';
export 'src/layout/starry_gradient_fallback.dart';
export 'src/layout/starry_immersive_background.dart';
export 'src/layout/starry_master_detail_layout.dart';
export 'src/layout/starry_group_card.dart';
export 'src/layout/starry_section_header.dart';
export 'src/layout/starry_settings_tile.dart';

// Navigation.
export 'src/navigation/starry_dock_bar.dart';
export 'src/navigation/starry_navigation_pane.dart';
export 'src/navigation/starry_page_top_bar.dart';
export 'src/navigation/starry_round_action_button.dart';
export 'src/navigation/starry_sliver_page_top_bar.dart';

// Tags.
export 'src/tags/starry_badge.dart';
export 'src/tags/starry_chip.dart';
export 'src/tags/starry_tag.dart';
