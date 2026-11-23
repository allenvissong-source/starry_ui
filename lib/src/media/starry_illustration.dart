/// Bundled Starry illustrations. The host supplies localized copy and actions.
enum StarryIllustration {
  noContent('assets/illustrations/states/empty/no_content.webp');

  const StarryIllustration(this.assetPath);

  final String assetPath;

  static const packageName = 'starry_ui';
}
