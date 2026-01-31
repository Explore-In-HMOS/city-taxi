// COLOR PALETTE
export class AppColors {
  // Backgrounds
  static readonly BACKGROUND = '#000000'; // Pure black (OLED optimization)
  static readonly CARD = '#242428'; // Dark card background
  static readonly CARD_ELEVATED = '#32323A'; // Slightly elevated cards
  static readonly CARD_ACCENT = '#252B3A'; // Accent Card Background

  // Text
  static readonly TEXT_PRIMARY = '#FFFFFF'; // Primary text
  static readonly TEXT_SECONDARY = '#ffededf3'; // Secondary text
  static readonly TEXT_TERTIARY = '#ffd4d4db'; // Tertiary text
  static readonly TEXT_DISABLED = '#ffb4b4bc'; // Disabled text

  // Accent Colors
  static readonly ACCENT_PRIMARY = '#6B9BE8'; // Soft blue
  static readonly ACCENT_SECONDARY = '#5A8DD6'; // Deeper blue
  static readonly ACCENT_TERTIARY = '#8BA8D8'; // Muted blue-purple
  static readonly ACCENT_QUATERNARY = '#7BB5E8'; // Sky blue

  // Semantic Colors
  static readonly SUCCESS = '#5EC98A'; // Success
  static readonly WARNING = '#E8B86B'; // Warning
  static readonly ERROR = '#E86B6B'; // Error critical
  static readonly INFO = '#7BB5E8'; // Informational

  // UI Elements
  static readonly BORDER = '#3A3A42'; // Borders and dividers
  static readonly BORDER_LIGHT = '#4A4A52'; // Lighter borders
  static readonly FOCUS = '#6B9BE8'; // Focus indicator
  static readonly OVERLAY = 'rgba(0, 0, 0, 0.7)'; // Modal overlays

  // Interactive States
  static readonly BUTTON_PRIMARY = '#6B9BE8'; // Primary action button
  static readonly BUTTON_PRIMARY_PRESSED = '#5A8DD6'; // Deeper blue
  static readonly BUTTON_SECONDARY = '#3A3A42'; // Secondary button
  static readonly BUTTON_SECONDARY_PRESSED = '#4A4A52'; // Secondary button pressed
  static readonly BUTTON_OUTLINE = '#9CCDFC'; // Outline button
  static readonly BUTTON_OUTLINE_BORDER = '#8BA8D8'; // Outline button border
  static readonly BUTTON_OUTLINE_PRESSED = 'rgba(107, 155, 232, 0.2)'; // Outline button pressed
  static readonly BUTTON_SUCCESS = '#5EC98A'; // Success actions
  static readonly BUTTON_DANGER = '#E86B6B'; // Destructive actions
  static readonly BUTTON_DISABLED = '#ff5479ae'; // Disabled button

  // Utility
  static readonly TRANSPARENT = 'rgba(0, 0, 0, 0)';
}

// TYPOGRAPHY
export class AppFonts {
  // Font Sizes
  static readonly SIZE_HERO = 40; // Hero text
  static readonly SIZE_TITLE_LARGE = 24; // Large titles
  static readonly SIZE_TITLE = 20; // Standard titles
  static readonly SIZE_BODY_LARGE = 16; // Large body text
  static readonly SIZE_BODY = 14; // Standard body text
  static readonly SIZE_CAPTION = 12; // Captions labels
  static readonly SIZE_SMALL = 10; // Very small text

  // Font Weights
  static readonly WEIGHT_LIGHT = FontWeight.Lighter;
  static readonly WEIGHT_REGULAR = FontWeight.Normal;
  static readonly WEIGHT_MEDIUM = FontWeight.Medium;
  static readonly WEIGHT_SEMIBOLD = 600;
  static readonly WEIGHT_BOLD = FontWeight.Bold;
}

// Spaces in the app
export class AppLayout {
  // Spacing (For padding, margins and gaps)
  static readonly SPACING_XS = 4;
  static readonly SPACING_SM = 8;
  static readonly SPACING_MD = 12;
  static readonly SPACING_LG = 16;
  static readonly SPACING_XL = 20;
  static readonly SPACING_XXL = 24;
  // Border Radius
  static readonly RADIUS_SM = 8;
  static readonly RADIUS_MD = 12;
  static readonly RADIUS_LG = 16;
  static readonly RADIUS_XL = 20;
  static readonly RADIUS_CIRCLE = 999;
  // Icon Sizes
  static readonly ICON_XS = 16;
  static readonly ICON_SM = 20;
  static readonly ICON_MD = 24;
  static readonly ICON_LG = 32;
  static readonly ICON_XL = 48;
  static readonly ICON_XXL = 64;
  // Button Dimensions
  static readonly BUTTON_HEIGHT_SM = 40;
  static readonly BUTTON_HEIGHT_MD = 48;
  static readonly BUTTON_HEIGHT_LG = 56;
  static readonly BUTTON_PADDING_HORIZONTAL = this.SPACING_XL;
  static readonly BUTTON_PADDING_VERTICAL = this.SPACING_MD;
  // Status Indicator
  static readonly STATUS_DOT_SM = 8;
  static readonly STATUS_DOT_LG = 12;
}
