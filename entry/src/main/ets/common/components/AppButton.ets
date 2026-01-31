import { AppColors, AppFonts, AppLayout } from '../constants/UIConstants';

// App-wide button components

export enum AppButtonType {
  primary = 'primary', // Primary, filled, accent color
  secondary = 'secondary', // attributes: Secondary, filled, grayscale
  outline = 'outline', // Outline, transparent, accent color as border and text
  iconCircle = 'iconCircle', // Circular icon-only button
  arc = 'arc' // Arc button for bottom of screen
}

export enum AppButtonSize {
  small = 'small',
  standard = 'standard',
  large = 'large'
}

@Component
export struct AppButton {
  // Required props
  @Prop text: string = ''; // Optional for icon variant
  // Optional props with defaults
  onButtonClick?: () => void;
  @Prop type: AppButtonType = AppButtonType.primary;
  @Prop buttonSize: AppButtonSize = AppButtonSize.standard;
  @Prop icon: ResourceStr;
  @Prop iconText: string = '';
  @Prop iconButtonColor: string = '';
  @Prop disabled: boolean = false;
  @Prop fullWidth: boolean = false;
  @Prop loading: boolean = false;
  @State pressed: boolean = false;

  private _isDisabled(): boolean {
    return this.disabled || this.loading || !this.onButtonClick;
  }

  build() {
    if (this.type === AppButtonType.iconCircle) {
      // Circular icon-only button
      Column() {
        if (this.loading) {
          LoadingProgress()
            .width(this._getIconButtonIconSize())
            .height(this._getIconButtonIconSize())
            .color(this._getTextColor())
        } else if (this.icon) {
          Image(this.icon)
            .width(this._getIconButtonIconSize())
            .height(this._getIconButtonIconSize())
            .objectFit(ImageFit.Contain)
            .fillColor(this._getTextColor())
        } else if (this.iconText) {
          Text(this.iconText)
            .fontSize(this._getIconButtonFontSize())
            .fontColor(this._getTextColor())
        }
      }
      .width(this._getHeight())
      .height(this._getHeight())
      .borderRadius(AppLayout.RADIUS_CIRCLE)
      .backgroundColor(this._getBackgroundColor())
      .justifyContent(FlexAlign.Center)
      .scale({ x: this.pressed && !this._isDisabled() ? 0.95 : 1, y: this.pressed && !this._isDisabled() ? 0.95 : 1 })
      .animation({
        duration: 150,
        curve: Curve.Sharp
      })
      .onTouch((event: TouchEvent) => {
        if (!this._isDisabled()) {
          if (event.type === TouchType.Down) {
            this.pressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressed = false;
          }
        }
      })
      .onClick(() => {
        if (!this._isDisabled() && this.onButtonClick) {
          this.onButtonClick();
        }
      })
    } else if (this.type === AppButtonType.arc) {
      Column() {
        if (this.loading) {
          LoadingProgress()
            .width(this._getIconSize())
            .height(this._getIconSize())
            .color(this._getTextColor())
        } else {
          Text(this.text)
            .fontSize(this._getFontSize())
            .fontWeight(AppFonts.WEIGHT_SEMIBOLD)
            .fontColor(this._getTextColor())
        }
      }
      .width('100%')
      .height(AppLayout.BUTTON_HEIGHT_MD)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this._getBackgroundColor())
      .borderRadius({
        topLeft: 36,
        topRight: 36,
        bottomLeft: 0,
        bottomRight: 0
      })
      .scale({ x: this.pressed && !this._isDisabled() ? 0.98 : 1, y: this.pressed && !this._isDisabled() ? 0.98 : 1 })
      .animation({
        duration: 150,
        curve: Curve.Sharp
      })
      .onTouch((event: TouchEvent) => {
        if (!this._isDisabled()) {
          if (event.type === TouchType.Down) {
            this.pressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressed = false;
          }
        }
      })
      .onClick(() => {
        if (!this._isDisabled() && this.onButtonClick) {
          this.onButtonClick();
        }
      })
    } else { // Other buttons: Primary, Secondary, Outline
      Row({ space: AppLayout.SPACING_SM }) {
        if (this.loading) {
          LoadingProgress()
            .width(this._getIconSize())
            .height(this._getIconSize())
            .color(this._getTextColor())
        } else if (this.icon) {
          Image(this.icon)
            .width(this._getIconSize())
            .height(this._getIconSize())
            .objectFit(ImageFit.Contain)
            .fillColor(this._getTextColor())
        }

        Text(this.text)
          .fontSize(this._getFontSize())
          .fontWeight(AppFonts.WEIGHT_SEMIBOLD)
          .fontColor(this._getTextColor())
      }
      .width(this.fullWidth ? '100%' : undefined)
      .height(this._getHeight())
      .padding({
        left: AppLayout.BUTTON_PADDING_HORIZONTAL,
        right: AppLayout.BUTTON_PADDING_HORIZONTAL
      })
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this._getBackgroundColor())
      .borderRadius(AppLayout.RADIUS_CIRCLE)
      .border(this._getBorder())
      .scale({ x: this.pressed && !this._isDisabled() ? 0.98 : 1, y: this.pressed && !this._isDisabled() ? 0.98 : 1 })
      .animation({
        duration: 150,
        curve: Curve.Sharp
      })
      .onTouch((event: TouchEvent) => {
        if (!this._isDisabled()) {
          if (event.type === TouchType.Down) {
            this.pressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.pressed = false;
          }
        }
      })
      .onClick(() => {
        if (!this._isDisabled() && this.onButtonClick) {
          this.onButtonClick();
        }
      })
    }
  }

  private _getBackgroundColor(): string {
    if (this._isDisabled()) {
      return AppColors.BUTTON_DISABLED;
    }
    switch (this.type) {
      case AppButtonType.primary:
        return this.pressed ? AppColors.BUTTON_PRIMARY_PRESSED : AppColors.BUTTON_PRIMARY;
      case AppButtonType.secondary:
        return this.pressed ? AppColors.BUTTON_SECONDARY_PRESSED : AppColors.BUTTON_SECONDARY;
      case AppButtonType.outline:
        return this.pressed ? AppColors.BUTTON_OUTLINE_PRESSED : AppColors.TRANSPARENT;
      case AppButtonType.iconCircle:
        if (this.iconButtonColor) {
          return this.iconButtonColor;
        }
        return this.pressed ? AppColors.BUTTON_SECONDARY_PRESSED : AppColors.BUTTON_SECONDARY;
      default:
        return AppColors.BUTTON_PRIMARY;
    }
  }

  private _getTextColor(): string {
    if (this._isDisabled()) {
      return AppColors.TEXT_DISABLED;
    }
    if (this.type === AppButtonType.outline) {
      return AppColors.BUTTON_OUTLINE;
    }

    return AppColors.TEXT_PRIMARY;
  }

  private _getBorder(): BorderOptions {
    if (this.type === AppButtonType.outline) {
      return {
        width: 1.5,
        color: this.pressed ? AppColors.BUTTON_OUTLINE : AppColors.BUTTON_OUTLINE_BORDER,
        style: BorderStyle.Solid
      };
    }

    return { width: 0 };
  }

  private _getHeight(): number {
    switch (this.buttonSize) {
      case (AppButtonSize.small):
        return AppLayout.BUTTON_HEIGHT_SM;
      case (AppButtonSize.large):
        return AppLayout.BUTTON_HEIGHT_LG;
      default:
        return AppLayout.BUTTON_HEIGHT_MD;
    }
  }

  private _getFontSize(): number {
    switch (this.buttonSize) {
      case (AppButtonSize.small):
        return AppFonts.SIZE_CAPTION;
      case (AppButtonSize.large):
        return AppFonts.SIZE_BODY_LARGE;
      default:
        return AppFonts.SIZE_BODY;
    }
  }

  private _getIconSize(): number {
    switch (this.buttonSize) {
      case (AppButtonSize.small):
        return AppLayout.ICON_XS;
      case (AppButtonSize.large):
        return AppLayout.ICON_MD;
      default:
        return AppLayout.ICON_SM;
    }
  }

  private _getIconButtonIconSize(): number {
    switch (this.buttonSize) {
      case (AppButtonSize.small):
        return AppLayout.ICON_MD;
      case (AppButtonSize.large):
        return AppLayout.ICON_XL;
      default:
        return AppLayout.ICON_LG;
    }
  }

  private _getIconButtonFontSize(): number {
    switch (this.buttonSize) {
      case (AppButtonSize.small):
        return AppFonts.SIZE_BODY;
      case (AppButtonSize.large):
        return AppFonts.SIZE_TITLE_LARGE;
      default:
        return AppFonts.SIZE_TITLE;
    }
  }
}