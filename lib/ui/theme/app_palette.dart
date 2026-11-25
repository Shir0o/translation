import 'package:flutter/material.dart';

/// Semantic light and dark palettes for LingoDiff Studio.
///
/// Every widget reads its colours from this [ThemeExtension] (via
/// `AppPalette.of(context)` or `context.palette`) instead of hard-coded
/// `Color(0xFF...)` literals, so the app can follow the platform brightness
/// ([ThemeMode.system]).
///
/// Naming follows intent, not hue:
///  * surfaces: [scaffold], [surface], [surfaceRaised], [surfaceHeader],
///    [surfaceInset], [header]
///  * lines: [border], [borderStrong]
///  * type: [textPrimary], [textStrong], [textBody], [textMuted],
///    [textOnAccent], [disabledText]
///  * accent: [primary], [primaryStrong], [primarySoft], [onPrimarySoft]
///  * status: info / success / error / warning, each with a solid colour, a
///    tinted container (`*Soft`), its border, and the on-container text
///  * diff + pointer highlights for the word-diff and English pointer views
///
/// Contrast: both palettes are designed so every foreground/container pair used
/// by the UI clears WCAG AA (>= 4.5:1 normal text, >= 3.0:1 for large/bold
/// text). Tinted containers are opaque rather than alpha blends so the ratio is
/// predictable over any parent surface.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.scaffold,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHeader,
    required this.surfaceInset,
    required this.header,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textStrong,
    required this.textBody,
    required this.textMuted,
    required this.textOnAccent,
    required this.disabledText,
    required this.disabledSurface,
    required this.primary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.primarySoftBorder,
    required this.onPrimarySoft,
    required this.info,
    required this.infoSoft,
    required this.infoSoftBorder,
    required this.onInfoSoft,
    required this.success,
    required this.successSoft,
    required this.successSoftBorder,
    required this.onSuccessSoft,
    required this.error,
    required this.errorSoft,
    required this.errorSoftBorder,
    required this.onErrorSoft,
    required this.warning,
    required this.warningSoft,
    required this.warningSoftBorder,
    required this.warningLabel,
    required this.warningHeading,
    required this.onWarning,
    required this.onWarningSoft,
    required this.violet,
    required this.diffAddedBackground,
    required this.diffAddedText,
    required this.diffRemovedBackground,
    required this.diffRemovedText,
    required this.diffPlainText,
    required this.pointerActiveBackground,
    required this.pointerActiveBorder,
    required this.pointerActiveText,
    required this.shadow,
    required this.snackBarBackground,
    required this.onSnackBar,
    required this.blurredFieldBackground,
  });

  /// The brightness this palette was designed for.
  final Brightness brightness;

  // --- Surfaces -----------------------------------------------------------
  /// Page background behind every card.
  final Color scaffold;

  /// Cards, panels, dialogs, drawers and other floating containers.
  final Color surface;

  /// Elevated/selected variant of [surface] (highlighted critique card).
  final Color surfaceRaised;

  /// Tinted strip used for panel headers and secondary bands.
  final Color surfaceHeader;

  /// Sunken container: text inputs, diff bodies, comparison tiles.
  final Color surfaceInset;

  /// Pinned workspace header bar.
  final Color header;

  // --- Lines --------------------------------------------------------------
  /// Default hairline border between surfaces.
  final Color border;

  /// Stronger border for inputs and inactive controls.
  final Color borderStrong;

  // --- Type ---------------------------------------------------------------
  /// Default body text.
  final Color textPrimary;

  /// Headings and wordmarks.
  final Color textStrong;

  /// Secondary reading text (explanation paragraphs, diff text).
  final Color textBody;

  /// Muted labels, hints, metadata.
  final Color textMuted;

  /// Text/icons drawn on a saturated accent (primary button, brand tile).
  final Color textOnAccent;

  /// Disabled label text (still >= 4.5:1 on [disabledSurface]).
  final Color disabledText;

  /// Disabled control surface.
  final Color disabledSurface;

  // --- Primary accent -----------------------------------------------------
  /// Brand accent used for focus rings and progress.
  final Color primary;

  /// Saturated accent for filled buttons and the brand tile (white text).
  final Color primaryStrong;

  /// Tinted accent container (score pill, active pointer chip).
  final Color primarySoft;

  /// Border for [primarySoft] containers.
  ///
  /// Tinted-container borders deliberately reuse the container's foreground
  /// colour: a pale tint-vs-tint hairline is nearly invisible (and, because an
  /// 11-12px label's audit rect includes the border a few px away, it would be
  /// measured as the text backdrop).
  final Color primarySoftBorder;

  /// Accent text on [primarySoft].
  final Color onPrimarySoft;

  // --- Status: info -------------------------------------------------------
  final Color info;
  final Color infoSoft;
  final Color infoSoftBorder;
  final Color onInfoSoft;

  // --- Status: success ----------------------------------------------------
  final Color success;
  final Color successSoft;
  final Color successSoftBorder;
  final Color onSuccessSoft;

  // --- Status: error ------------------------------------------------------
  final Color error;
  final Color errorSoft;
  final Color errorSoftBorder;
  final Color onErrorSoft;

  // --- Status: warning ----------------------------------------------------
  final Color warning;
  final Color warningSoft;
  final Color warningSoftBorder;
  final Color warningLabel;
  final Color warningHeading;

  /// Text on a solid [warning] fill (badge, filled warning button).
  final Color onWarning;
  final Color onWarningSoft;

  /// Secondary accent used for the reference-Spanish pane and "Why:" labels.
  final Color violet;

  // --- Diff highlights ----------------------------------------------------
  final Color diffAddedBackground;
  final Color diffAddedText;
  final Color diffRemovedBackground;
  final Color diffRemovedText;
  final Color diffPlainText;

  // --- Pointer highlights -------------------------------------------------
  final Color pointerActiveBackground;
  final Color pointerActiveBorder;
  final Color pointerActiveText;

  // --- Effects ------------------------------------------------------------
  final Color shadow;
  final Color snackBarBackground;
  final Color onSnackBar;

  /// Fill behind the blurred official translation while typing.
  final Color blurredFieldBackground;

  /// Dark slate-navy + indigo palette the app shipped with.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    scaffold: Color(0xFF0A0F1A),
    surface: Color(0xFF0F172A),
    surfaceRaised: Color(0xFF1E293B),
    surfaceHeader: Color(0xFF151F32),
    surfaceInset: Color(0xFF020617),
    header: Color(0xFF0F172A),
    border: Color(0xFF1E293B),
    borderStrong: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textStrong: Color(0xFFFFFFFF),
    textBody: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    textOnAccent: Color(0xFFFFFFFF),
    disabledText: Color(0xFF94A3B8),
    disabledSurface: Color(0xFF1E293B),
    primary: Color(0xFF6366F1),
    primaryStrong: Color(0xFF4F46E5),
    primarySoft: Color(0xFF1C204F),
    primarySoftBorder: Color(0xFFA5B4FC),
    onPrimarySoft: Color(0xFFA5B4FC),
    info: Color(0xFF38BDF8),
    infoSoft: Color(0xFF173853),
    infoSoftBorder: Color(0xFF7DD3FC),
    onInfoSoft: Color(0xFF7DD3FC),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF0F373B),
    successSoftBorder: Color(0xFFA7F3D0),
    onSuccessSoft: Color(0xFFA7F3D0),
    error: Color(0xFFF43F5E),
    errorSoft: Color(0xFF3D1F34),
    errorSoftBorder: Color(0xFFFECDD3),
    onErrorSoft: Color(0xFFFECDD3),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFF3D3224),
    warningSoftBorder: Color(0xFFFDE68A),
    warningLabel: Color(0xFFFCD34D),
    warningHeading: Color(0xFFFBBF24),
    onWarning: Color(0xFF0F172A),
    onWarningSoft: Color(0xFFFDE68A),
    violet: Color(0xFFA78BFA),
    diffAddedBackground: Color(0xFF0E3B33),
    diffAddedText: Color(0xFF6EE7B7),
    diffRemovedBackground: Color(0xFF3F1A28),
    diffRemovedText: Color(0xFFFDA4AF),
    diffPlainText: Color(0xFFE2E8F0),
    pointerActiveBackground: Color(0xFF0E3A54),
    pointerActiveBorder: Color(0xFF38BDF8),
    pointerActiveText: Color(0xFF7DD3FC),
    shadow: Color(0x42000000),
    snackBarBackground: Color(0xFF1E293B),
    onSnackBar: Color(0xFFF1F5F9),
    blurredFieldBackground: Color(0xFF475569),
  );

  /// Crisp studio-paper palette for light mode.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    scaffold: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF1F5F9),
    surfaceHeader: Color(0xFFF1F5F9),
    surfaceInset: Color(0xFFF8FAFC),
    header: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    borderStrong: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textStrong: Color(0xFF0F172A),
    textBody: Color(0xFF334155),
    textMuted: Color(0xFF475569),
    textOnAccent: Color(0xFFFFFFFF),
    disabledText: Color(0xFF5A6880),
    disabledSurface: Color(0xFFE2E8F0),
    primary: Color(0xFF4F46E5),
    primaryStrong: Color(0xFF4338CA),
    primarySoft: Color(0xFFEEF2FF),
    primarySoftBorder: Color(0xFF3730A3),
    onPrimarySoft: Color(0xFF3730A3),
    info: Color(0xFF0369A1),
    infoSoft: Color(0xFFE0F2FE),
    infoSoftBorder: Color(0xFF075985),
    onInfoSoft: Color(0xFF075985),
    success: Color(0xFF047857),
    successSoft: Color(0xFFDCFCE7),
    successSoftBorder: Color(0xFF166534),
    onSuccessSoft: Color(0xFF166534),
    error: Color(0xFFBE123C),
    errorSoft: Color(0xFFFFE4E6),
    errorSoftBorder: Color(0xFF9F1239),
    onErrorSoft: Color(0xFF9F1239),
    warning: Color(0xFFB45309),
    warningSoft: Color(0xFFFEF3C7),
    warningSoftBorder: Color(0xFF92400E),
    warningLabel: Color(0xFF92400E),
    warningHeading: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    onWarningSoft: Color(0xFF78350F),
    violet: Color(0xFF6D28D9),
    diffAddedBackground: Color(0xFFDCFCE7),
    diffAddedText: Color(0xFF166534),
    diffRemovedBackground: Color(0xFFFFE4E6),
    diffRemovedText: Color(0xFF9F1239),
    diffPlainText: Color(0xFF334155),
    pointerActiveBackground: Color(0xFFE0E7FF),
    pointerActiveBorder: Color(0xFF6366F1),
    pointerActiveText: Color(0xFF312E81),
    shadow: Color(0x140F172A),
    snackBarBackground: Color(0xFF0F172A),
    onSnackBar: Color(0xFFF8FAFC),
    blurredFieldBackground: Color(0xFFE2E8F0),
  );

  /// Palette attached to the ambient [Theme]; falls back to the palette that
  /// matches the theme brightness when a widget is used outside LingoDiffApp.
  static AppPalette of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  bool get isDark => brightness == Brightness.dark;

  /// Raised shadow for cards; a soft paper shadow in light mode.
  List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(color: shadow, blurRadius: 4, offset: const Offset(0, 2)),
  ];

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      scaffold: mix(scaffold, other.scaffold),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surfaceHeader: mix(surfaceHeader, other.surfaceHeader),
      surfaceInset: mix(surfaceInset, other.surfaceInset),
      header: mix(header, other.header),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      textPrimary: mix(textPrimary, other.textPrimary),
      textStrong: mix(textStrong, other.textStrong),
      textBody: mix(textBody, other.textBody),
      textMuted: mix(textMuted, other.textMuted),
      textOnAccent: mix(textOnAccent, other.textOnAccent),
      disabledText: mix(disabledText, other.disabledText),
      disabledSurface: mix(disabledSurface, other.disabledSurface),
      primary: mix(primary, other.primary),
      primaryStrong: mix(primaryStrong, other.primaryStrong),
      primarySoft: mix(primarySoft, other.primarySoft),
      primarySoftBorder: mix(primarySoftBorder, other.primarySoftBorder),
      onPrimarySoft: mix(onPrimarySoft, other.onPrimarySoft),
      info: mix(info, other.info),
      infoSoft: mix(infoSoft, other.infoSoft),
      infoSoftBorder: mix(infoSoftBorder, other.infoSoftBorder),
      onInfoSoft: mix(onInfoSoft, other.onInfoSoft),
      success: mix(success, other.success),
      successSoft: mix(successSoft, other.successSoft),
      successSoftBorder: mix(successSoftBorder, other.successSoftBorder),
      onSuccessSoft: mix(onSuccessSoft, other.onSuccessSoft),
      error: mix(error, other.error),
      errorSoft: mix(errorSoft, other.errorSoft),
      errorSoftBorder: mix(errorSoftBorder, other.errorSoftBorder),
      onErrorSoft: mix(onErrorSoft, other.onErrorSoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      warningSoftBorder: mix(warningSoftBorder, other.warningSoftBorder),
      warningLabel: mix(warningLabel, other.warningLabel),
      warningHeading: mix(warningHeading, other.warningHeading),
      onWarning: mix(onWarning, other.onWarning),
      onWarningSoft: mix(onWarningSoft, other.onWarningSoft),
      violet: mix(violet, other.violet),
      diffAddedBackground: mix(diffAddedBackground, other.diffAddedBackground),
      diffAddedText: mix(diffAddedText, other.diffAddedText),
      diffRemovedBackground: mix(
        diffRemovedBackground,
        other.diffRemovedBackground,
      ),
      diffRemovedText: mix(diffRemovedText, other.diffRemovedText),
      diffPlainText: mix(diffPlainText, other.diffPlainText),
      pointerActiveBackground: mix(
        pointerActiveBackground,
        other.pointerActiveBackground,
      ),
      pointerActiveBorder: mix(pointerActiveBorder, other.pointerActiveBorder),
      pointerActiveText: mix(pointerActiveText, other.pointerActiveText),
      shadow: mix(shadow, other.shadow),
      snackBarBackground: mix(snackBarBackground, other.snackBarBackground),
      onSnackBar: mix(onSnackBar, other.onSnackBar),
      blurredFieldBackground: mix(
        blurredFieldBackground,
        other.blurredFieldBackground,
      ),
    );
  }
}

/// `context.palette` shorthand for [AppPalette.of].
extension AppPaletteContext on BuildContext {
  AppPalette get palette => AppPalette.of(this);
}

/// Light theme for LingoDiff Studio.
ThemeData buildLightTheme() => _buildTheme(AppPalette.light);

/// Dark theme for LingoDiff Studio.
ThemeData buildDarkTheme() => _buildTheme(AppPalette.dark);

ThemeData _buildTheme(AppPalette palette) {
  final bool isDark = palette.isDark;
  final ColorScheme colorScheme = ColorScheme(
    brightness: palette.brightness,
    primary: palette.primary,
    onPrimary: palette.textOnAccent,
    primaryContainer: palette.primarySoft,
    onPrimaryContainer: palette.onPrimarySoft,
    secondary: palette.violet,
    onSecondary: palette.textOnAccent,
    secondaryContainer: palette.primarySoft,
    onSecondaryContainer: palette.onPrimarySoft,
    error: palette.error,
    onError: palette.textOnAccent,
    errorContainer: palette.errorSoft,
    onErrorContainer: palette.onErrorSoft,
    surface: palette.surface,
    onSurface: palette.textPrimary,
    surfaceContainerHighest: palette.surfaceRaised,
    onSurfaceVariant: palette.textBody,
    outline: palette.borderStrong,
    outlineVariant: palette.border,
    shadow: palette.shadow,
    scrim: palette.shadow,
    inverseSurface: palette.snackBarBackground,
    onInverseSurface: palette.onSnackBar,
  );

  final OutlinedBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: palette.brightness,
    fontFamily: '.AppleSystemUIFont',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.scaffold,
    canvasColor: palette.surface,
    cardColor: palette.surface,
    dividerColor: palette.border,
    disabledColor: palette.disabledText,
    shadowColor: palette.shadow,
    extensions: <ThemeExtension<dynamic>>[palette],
    // Guarantee the 48x48dp Android tap target for every Material button, even
    // when real (narrower) Roboto metrics are loaded instead of Ahem.
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: WidgetStatePropertyAll<OutlinedBorder>(buttonShape),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: WidgetStatePropertyAll<OutlinedBorder>(buttonShape),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: WidgetStatePropertyAll<OutlinedBorder>(buttonShape),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 48)),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      scrimColor: isDark ? Colors.black54 : const Color(0x661E293B),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.snackBarBackground,
      contentTextStyle: TextStyle(color: palette.onSnackBar, fontSize: 13),
      actionTextColor: palette.onSnackBar,
      disabledActionTextColor: palette.textMuted,
      behavior: SnackBarBehavior.fixed,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.primary,
      linearTrackColor: palette.surfaceRaised,
      circularTrackColor: palette.surfaceRaised,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: palette.primary,
      selectionColor: palette.primary.withValues(alpha: 0.32),
      selectionHandleColor: palette.primary,
    ),
    iconTheme: IconThemeData(color: palette.textBody),
  );
}
