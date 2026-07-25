import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

import 'foundations.dart';

@UseCase(name: 'Colors', type: ColorsFoundation)
Widget colorsFoundation(BuildContext context) => const ColorsFoundation();

@UseCase(name: 'Radius', type: RadiusFoundation)
Widget radiusFoundation(BuildContext context) => const RadiusFoundation();

@UseCase(name: 'Elevation', type: ElevationFoundation)
Widget elevationFoundation(BuildContext context) => const ElevationFoundation();

@UseCase(name: 'Charts', type: ChartsFoundation)
Widget chartsFoundation(BuildContext context) => const ChartsFoundation();

@UseCase(name: 'Typography', type: TypographyFoundation)
Widget typographyFoundation(BuildContext context) => const TypographyFoundation();

@UseCase(name: 'Spacing', type: SpacingFoundation)
Widget spacingFoundation(BuildContext context) => const SpacingFoundation();

@UseCase(name: 'Motion', type: MotionFoundation)
Widget motionFoundation(BuildContext context) => const MotionFoundation();

@UseCase(name: 'Contrast Matrix', type: ContrastMatrixFoundation)
Widget contrastMatrixFoundation(BuildContext context) =>
    const ContrastMatrixFoundation();
