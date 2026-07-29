// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:starry_ui/src/buttons/starry_button.usecase.dart'
    as _starry_ui_src_buttons_starry_button_usecase;
import 'package:starry_ui/src/buttons/starry_icon_button.usecase.dart'
    as _starry_ui_src_buttons_starry_icon_button_usecase;
import 'package:starry_ui/src/buttons/starry_text_button.usecase.dart'
    as _starry_ui_src_buttons_starry_text_button_usecase;
import 'package:starry_ui/src/components/starry_card.usecase.dart'
    as _starry_ui_src_components_starry_card_usecase;
import 'package:starry_ui/src/components/starry_control_shell.usecase.dart'
    as _starry_ui_src_components_starry_control_shell_usecase;
import 'package:starry_ui/src/components/starry_expandable_card.usecase.dart'
    as _starry_ui_src_components_starry_expandable_card_usecase;
import 'package:starry_ui/src/feedback/starry_empty_state.usecase.dart'
    as _starry_ui_src_feedback_starry_empty_state_usecase;
import 'package:starry_ui/src/feedback/starry_loading_indicator.usecase.dart'
    as _starry_ui_src_feedback_starry_loading_indicator_usecase;
import 'package:starry_ui/src/feedback/starry_looping_animations.usecase.dart'
    as _starry_ui_src_feedback_starry_looping_animations_usecase;
import 'package:starry_ui/src/feedback/starry_message_list.usecase.dart'
    as _starry_ui_src_feedback_starry_message_list_usecase;
import 'package:starry_ui/src/foundations/foundations.usecase.dart'
    as _starry_ui_src_foundations_foundations_usecase;
import 'package:starry_ui/src/inputs/starry_search_input.usecase.dart'
    as _starry_ui_src_inputs_starry_search_input_usecase;
import 'package:starry_ui/src/inputs/starry_switch.usecase.dart'
    as _starry_ui_src_inputs_starry_switch_usecase;
import 'package:starry_ui/src/inputs/starry_text_field.usecase.dart'
    as _starry_ui_src_inputs_starry_text_field_usecase;
import 'package:starry_ui/src/inputs/starry_textarea.usecase.dart'
    as _starry_ui_src_inputs_starry_textarea_usecase;
import 'package:starry_ui/src/layout/starry_page_wrapper.usecase.dart'
    as _starry_ui_src_layout_starry_page_wrapper_usecase;
import 'package:starry_ui/src/overlays/starry_overlay_background.usecase.dart'
    as _starry_ui_src_overlays_starry_overlay_background_usecase;
import 'package:starry_ui/src/tags/starry_badge.usecase.dart'
    as _starry_ui_src_tags_starry_badge_usecase;
import 'package:starry_ui/src/tags/starry_chip.usecase.dart'
    as _starry_ui_src_tags_starry_chip_usecase;
import 'package:starry_ui/src/tags/starry_tag.usecase.dart'
    as _starry_ui_src_tags_starry_tag_usecase;
import 'package:starry_ui/src/text/starry_emoji_text.usecase.dart'
    as _starry_ui_src_text_starry_emoji_text_usecase;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'buttons',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Disabled',
            builder: _starry_ui_src_buttons_starry_button_usecase
                .disabledStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Filled',
            builder:
                _starry_ui_src_buttons_starry_button_usecase.filledStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Loading',
            builder: _starry_ui_src_buttons_starry_button_usecase
                .loadingStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Secondary',
            builder: _starry_ui_src_buttons_starry_button_usecase
                .secondaryStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Tonal',
            builder:
                _starry_ui_src_buttons_starry_button_usecase.tonalStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With Icon',
            builder:
                _starry_ui_src_buttons_starry_button_usecase.iconStarryButton,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryIconButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All Variants',
            builder: _starry_ui_src_buttons_starry_icon_button_usecase
                .allVariantsStarryIconButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_buttons_starry_icon_button_usecase
                .playgroundStarryIconButton,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTextButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder: _starry_ui_src_buttons_starry_text_button_usecase
                .allStatesStarryTextButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_buttons_starry_text_button_usecase
                .playgroundStarryTextButton,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryAnimatedControlShell',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Animated',
            builder: _starry_ui_src_components_starry_control_shell_usecase
                .animatedStarryControlShell,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder: _starry_ui_src_components_starry_card_usecase
                .allStatesStarryCard,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_components_starry_card_usecase
                .playgroundStarryCard,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryControlShell',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder: _starry_ui_src_components_starry_control_shell_usecase
                .allStatesStarryControlShell,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryExpandableCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_components_starry_expandable_card_usecase
                .defaultStarryExpandableCard,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Initially Expanded',
            builder: _starry_ui_src_components_starry_expandable_card_usecase
                .expandedStarryExpandableCard,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_components_starry_expandable_card_usecase
                .playgroundStarryExpandableCard,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryRoundIconShell',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Round Icon',
            builder: _starry_ui_src_components_starry_control_shell_usecase
                .roundIconStarryControlShell,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'feedback',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryEmptyState',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_feedback_starry_empty_state_usecase
                .defaultStarryEmptyState,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_feedback_starry_empty_state_usecase
                .playgroundStarryEmptyState,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With Action',
            builder: _starry_ui_src_feedback_starry_empty_state_usecase
                .withActionStarryEmptyState,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryFullScreenLoadingIndicator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Full Screen',
            builder: _starry_ui_src_feedback_starry_loading_indicator_usecase
                .fullScreenStarryLoadingIndicator,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryLoadingIndicator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_feedback_starry_loading_indicator_usecase
                .defaultStarryLoadingIndicator,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_feedback_starry_loading_indicator_usecase
                .playgroundStarryLoadingIndicator,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryMessageList',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Empty',
            builder: _starry_ui_src_feedback_starry_message_list_usecase
                .emptyStarryMessageList,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_feedback_starry_message_list_usecase
                .playgroundStarryMessageList,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With Items',
            builder: _starry_ui_src_feedback_starry_message_list_usecase
                .withItemsStarryMessageList,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryPulsingWidget',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Pulsing',
            builder: _starry_ui_src_feedback_starry_looping_animations_usecase
                .pulsingStarryLoopingAnimation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryRotatingWidget',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Rotating',
            builder: _starry_ui_src_feedback_starry_looping_animations_usecase
                .rotatingStarryLoopingAnimation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryScalingWidget',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Scaling',
            builder: _starry_ui_src_feedback_starry_looping_animations_usecase
                .scalingStarryLoopingAnimation,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'foundations',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ChartsFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Charts',
            builder:
                _starry_ui_src_foundations_foundations_usecase.chartsFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ColorsFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Colors',
            builder:
                _starry_ui_src_foundations_foundations_usecase.colorsFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ContrastMatrixFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Contrast Matrix',
            builder: _starry_ui_src_foundations_foundations_usecase
                .contrastMatrixFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ControlMetricsFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Control Metrics',
            builder: _starry_ui_src_foundations_foundations_usecase
                .controlMetricsFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ElevationFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Elevation',
            builder: _starry_ui_src_foundations_foundations_usecase
                .elevationFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'MotionFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Motion',
            builder:
                _starry_ui_src_foundations_foundations_usecase.motionFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'RadiusFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Radius',
            builder:
                _starry_ui_src_foundations_foundations_usecase.radiusFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SpacingFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Spacing',
            builder: _starry_ui_src_foundations_foundations_usecase
                .spacingFoundation,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TypographyFoundation',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Typography',
            builder: _starry_ui_src_foundations_foundations_usecase
                .typographyFoundation,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'inputs',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarrySearchInput',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_inputs_starry_search_input_usecase
                .playgroundStarrySearchInput,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Variants',
            builder: _starry_ui_src_inputs_starry_search_input_usecase
                .variantsStarrySearchInput,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarrySwitch',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_inputs_starry_switch_usecase
                .playgroundStarrySwitch,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'States',
            builder:
                _starry_ui_src_inputs_starry_switch_usecase.statesStarrySwitch,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTextArea',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_inputs_starry_textarea_usecase
                .defaultStarryTextArea,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTextField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder: _starry_ui_src_inputs_starry_text_field_usecase
                .allStatesStarryTextField,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_inputs_starry_text_field_usecase
                .playgroundStarryTextField,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Slots & Multiline',
            builder: _starry_ui_src_inputs_starry_text_field_usecase
                .slotsStarryTextField,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'layout',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryPageWrapper',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_layout_starry_page_wrapper_usecase
                .defaultStarryPageWrapper,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_layout_starry_page_wrapper_usecase
                .playgroundStarryPageWrapper,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'overlays',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryOverlayBackground',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Light and Dark',
            builder: _starry_ui_src_overlays_starry_overlay_background_usecase
                .lightAndDarkStarryOverlayBackground,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_overlays_starry_overlay_background_usecase
                .playgroundStarryOverlayBackground,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'tags',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryBadge',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All Variants',
            builder:
                _starry_ui_src_tags_starry_badge_usecase.allVariantsStarryBadge,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder:
                _starry_ui_src_tags_starry_badge_usecase.playgroundStarryBadge,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryChip',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All Variants',
            builder:
                _starry_ui_src_tags_starry_chip_usecase.allVariantsStarryChip,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder:
                _starry_ui_src_tags_starry_chip_usecase.playgroundStarryChip,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTag',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder: _starry_ui_src_tags_starry_tag_usecase.allStatesStarryTag,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_tags_starry_tag_usecase.playgroundStarryTag,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'text',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryEmojiText',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_text_starry_emoji_text_usecase
                .defaultStarryEmojiText,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_text_starry_emoji_text_usecase
                .playgroundStarryEmojiText,
          ),
        ],
      ),
    ],
  ),
];
