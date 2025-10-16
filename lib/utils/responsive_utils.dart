import 'package:flutter/material.dart';

enum DeviceType { mobileSmall, mobileMedium, mobileLarge, tablet }

class ResponsiveUtils {
  // Umbrales de tamaño para los tipos de dispositivo
  static const double _mobileSmallThreshold = 360;
  static const double _mobileMediumThreshold = 540;
  static const double _tabletThreshold = 720;

  // Detectar tipo de dispositivo
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _tabletThreshold) return DeviceType.tablet;
    if (width >= _mobileMediumThreshold) return DeviceType.mobileLarge;
    if (width >= _mobileSmallThreshold) return DeviceType.mobileMedium;
    return DeviceType.mobileSmall;
  }

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;
  static bool isMobile(BuildContext context) =>
      deviceType(context) != DeviceType.tablet;
  static bool isSmallDevice(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileSmallThreshold;

  // Propiedades de pantalla
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double safeAreaWidth(BuildContext context) =>
      MediaQuery.of(context).padding.horizontal;
  static double safeAreaHeight(BuildContext context) =>
      MediaQuery.of(context).padding.vertical;

  // Escalado responsivo
  static double scaleWidth(BuildContext context, double factor) {
    final width = ResponsiveUtils.width(context);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return width * factor / devicePixelRatio.clamp(1.0, 2.0);
  }

  static double scaleHeight(BuildContext context, double factor) {
    final height = ResponsiveUtils.height(context);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return height * factor / devicePixelRatio.clamp(1.0, 2.0);
  }

  // Espaciadores responsivos
  static Widget hSpace(BuildContext context, double factor) {
    return SizedBox(width: scaleWidth(context, factor));
  }

  static Widget vSpace(BuildContext context, double factor) {
    return SizedBox(height: scaleHeight(context, factor));
  }

  // Padding responsivo
  static EdgeInsets screenPadding(BuildContext context) {
    final horizontal = scaleWidth(context, 0.04);
    final vertical = scaleHeight(context, 0.01);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: scaleWidth(context, 0.03),
      vertical: scaleHeight(context, 0.008),
    );
  }

  // Tipografía responsiva
  static TextStyle titleLarge(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 22 : 24,
    weight: FontWeight.w700,
    letterSpacing: 0.2,
  );
  static TextStyle titleMedium(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 18 : 20,
    weight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  static TextStyle titleSmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 16 : 18,
    weight: FontWeight.w600,
  );

  static TextStyle titleExtraSmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 12 : 14,
    weight: FontWeight.w600,
  );

  static TextStyle bodyLarge(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 14 : 16,
    weight: FontWeight.w500,
  );
  static TextStyle bodyMedium(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 12 : 14,
    weight: FontWeight.w400,
  );
  static TextStyle bodySmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 10 : 12,
    weight: FontWeight.w400,
  );
  static TextStyle buttonText(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 14 : 16,
    weight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Tamaños de íconos
  static double iconExtraSmall(BuildContext context) =>
      scaleWidth(context, 0.07);
  static double iconSmall(BuildContext context) => scaleWidth(context, 0.09);
  static double iconMedium(BuildContext context) => scaleWidth(context, 0.12);
  static double iconLarge(BuildContext context) => scaleWidth(context, 0.15);

  // Tamaños de tarjetas y botones
  static double cardElevation(BuildContext context) =>
      isSmallDevice(context) ? 2 : 4;
  static double buttonHeight(BuildContext context) =>
      scaleHeight(context, 0.07);
  static double cardBorderRadius(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double buttonBorderRadius(BuildContext context) =>
      scaleWidth(context, 0.04);

  static double buttonExtraSmall(BuildContext context) =>
      scaleHeight(context, 0.03);
  static double buttonSmallMedium(BuildContext context) =>
      scaleHeight(context, 0.04);
  static double buttonSmall(BuildContext context) => scaleHeight(context, 0.05);
  static double buttonLarge(BuildContext context) => scaleHeight(context, 0.09);
  static double buttonExtraLarge(BuildContext context) =>
      scaleHeight(context, 0.11);

  // Espaciado entre elementos
  static double extraSmallSpacing(BuildContext context) =>
      scaleWidth(context, 0.008);
  static double smallSpacing(BuildContext context) =>
      scaleWidth(context, 0.015);
  static double mediumSpacing(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double largeSpacing(BuildContext context) => scaleWidth(context, 0.05);

  // Border Radius
  static double cardBorderRadiusValue(BuildContext context) =>
      cardBorderRadius(context);
  static double buttonBorderRadiusValue(BuildContext context) =>
      buttonBorderRadius(context);
  static double extraSmallBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.015);
  static double smallBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.025);
  static double mediumBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double largeBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.04);

  // Section Divider Height & Spacing
  static double sectionDividerHeight(BuildContext context) =>
      scaleHeight(context, 0.025);
  static double sectionTitleSpacing(BuildContext context) =>
      scaleHeight(context, 0.05);

  // --- Métodos privados ---
  static TextStyle _getTextStyle(
    BuildContext context, {
    required double baseSize,
    FontWeight? weight,
    double letterSpacing = 0,
    bool usePrimaryColor = false,
  }) {
    final scale = _getFontScale(context, baseSize);
    final textTheme = Theme.of(context).textTheme;
    return textTheme.bodyLarge?.copyWith(
          fontSize: scale,
          fontWeight: weight ?? FontWeight.normal,
          letterSpacing: letterSpacing,
          color: usePrimaryColor ? Theme.of(context).colorScheme.primary : null,
        ) ??
        TextStyle(
          fontSize: scale,
          fontWeight: weight ?? FontWeight.normal,
          letterSpacing: letterSpacing,
        );
  }

  static double _getFontScale(BuildContext context, double baseSize) {
    const double minWidth = 320;
    const double maxWidth = 1200;
    const double minFontScale = 0.75;
    const double maxFontScale = 1.1;

    final width = ResponsiveUtils.width(context);
    final widthRatio = (width - minWidth) / (maxWidth - minWidth);
    final fontScale =
        minFontScale + (maxFontScale - minFontScale) * widthRatio.clamp(0, 1);

    if (isTablet(context)) {
      return (baseSize * fontScale).clamp(baseSize * 0.9, baseSize * 1.1);
    }
    return baseSize * fontScale;
  }
}

// Extension para uso más fluido
extension ResponsiveExtension on BuildContext {
  // Device
  DeviceType get deviceType => ResponsiveUtils.deviceType(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isSmallDevice => ResponsiveUtils.isSmallDevice(this);

  // Tamaño pantalla
  Size get screenSize => ResponsiveUtils.screenSize(this);
  double get width => ResponsiveUtils.width(this);
  double get height => ResponsiveUtils.height(this);

  // Espaciadores como widgets
  Widget hSpace(double factor) => ResponsiveUtils.hSpace(this, factor);
  Widget vSpace(double factor) => ResponsiveUtils.vSpace(this, factor);

  // Tipografía responsiva
  TextStyle get titleLarge => ResponsiveUtils.titleLarge(this);
  TextStyle get titleMedium => ResponsiveUtils.titleMedium(this);
  TextStyle get titleSmall => ResponsiveUtils.titleSmall(this);
  TextStyle get titleExtraSmall => ResponsiveUtils.titleExtraSmall(this);
  TextStyle get bodyLarge => ResponsiveUtils.bodyLarge(this);
  TextStyle get bodyMedium => ResponsiveUtils.bodyMedium(this);
  TextStyle get bodySmall => ResponsiveUtils.bodySmall(this);
  TextStyle get buttonText => ResponsiveUtils.buttonText(this);

  // Tamaños de íconos
  double get iconExtraSmall => ResponsiveUtils.iconExtraSmall(this);
  double get iconSmall => ResponsiveUtils.iconSmall(this);
  double get iconMedium => ResponsiveUtils.iconMedium(this);
  double get iconLarge => ResponsiveUtils.iconLarge(this);

  // Espaciados
  double get extraSmallSpacing => ResponsiveUtils.extraSmallSpacing(this);
  double get smallSpacing => ResponsiveUtils.smallSpacing(this);
  double get mediumSpacing => ResponsiveUtils.mediumSpacing(this);
  double get largeSpacing => ResponsiveUtils.largeSpacing(this);

  // Border Radius
  double get cardBorderRadiusValue =>
      ResponsiveUtils.cardBorderRadiusValue(this);
  double get buttonBorderRadiusValue =>
      ResponsiveUtils.buttonBorderRadiusValue(this);
  double get extraSmallBorderRadiusValue =>
      ResponsiveUtils.extraSmallBorderRadiusValue(this);
  double get smallBorderRadiusValue =>
      ResponsiveUtils.smallBorderRadiusValue(this);
  double get mediumBorderRadiusValue =>
      ResponsiveUtils.mediumBorderRadiusValue(this);
  double get largeBorderRadiusValue =>
      ResponsiveUtils.largeBorderRadiusValue(this);

  // Otros
  double get cardElevation => ResponsiveUtils.cardElevation(this);
  double get buttonHeight => ResponsiveUtils.buttonHeight(this);

  // Section Divider Height & Spacing
  double get sectionDividerHeight => ResponsiveUtils.sectionDividerHeight(this);
  double get sectionTitleSpacing => ResponsiveUtils.sectionTitleSpacing(this);

  // Padding
  EdgeInsets get screenPadding => ResponsiveUtils.screenPadding(this);
  EdgeInsets get cardPadding => ResponsiveUtils.cardPadding(this);
}
