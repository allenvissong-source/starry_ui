// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:starry_ui/src/components/starry_button.usecase.dart'
    as _starry_ui_src_components_starry_button_usecase;
import 'package:starry_ui/src/components/starry_card.usecase.dart'
    as _starry_ui_src_components_starry_card_usecase;
import 'package:starry_ui/src/components/starry_input.usecase.dart'
    as _starry_ui_src_components_starry_input_usecase;
import 'package:starry_ui/src/components/starry_switch.usecase.dart'
    as _starry_ui_src_components_starry_switch_usecase;
import 'package:starry_ui/src/components/starry_tag.usecase.dart'
    as _starry_ui_src_components_starry_tag_usecase;
import 'package:starry_ui/src/components/starry_textarea.usecase.dart'
    as _starry_ui_src_components_starry_textarea_usecase;
import 'package:starry_ui/src/foundations/foundations.usecase.dart'
    as _starry_ui_src_foundations_foundations_usecase;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StarryButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Disabled',
            builder: _starry_ui_src_components_starry_button_usecase
                .disabledStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Filled',
            builder: _starry_ui_src_components_starry_button_usecase
                .filledStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Secondary',
            builder: _starry_ui_src_components_starry_button_usecase
                .secondaryStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Tonal',
            builder: _starry_ui_src_components_starry_button_usecase
                .tonalStarryButton,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With Icon',
            builder: _starry_ui_src_components_starry_button_usecase
                .iconStarryButton,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _starry_ui_src_components_starry_card_usecase.defaultStarryCard,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Flat',
            builder:
                _starry_ui_src_components_starry_card_usecase.flatStarryCard,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_components_starry_card_usecase
                .playgroundStarryCard,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryInput',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_components_starry_input_usecase
                .defaultStarryInput,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Error',
            builder:
                _starry_ui_src_components_starry_input_usecase.errorStarryInput,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarrySwitch',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_components_starry_switch_usecase
                .playgroundStarrySwitch,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'States',
            builder: _starry_ui_src_components_starry_switch_usecase
                .statesStarrySwitch,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTag',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All States',
            builder:
                _starry_ui_src_components_starry_tag_usecase.allStatesStarryTag,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _starry_ui_src_components_starry_tag_usecase
                .playgroundStarryTag,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'StarryTextArea',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _starry_ui_src_components_starry_textarea_usecase
                .defaultStarryTextArea,
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
];
