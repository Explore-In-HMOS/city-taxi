import { AppColors, AppFonts } from '../constants/UIConstants';

// App-wide text component with variants

export enum AppTextVariant {
  hero = 'hero',
  titleLarge = 'titleLarge',
  title = 'title',
  bodyLarge = 'bodyLarge',
  body = 'body',
  caption = 'caption',
  small = 'small'
}

interface VariantConfig {
  fontSize: number,
  defaultWeight: FontWeight | number;
  defaultColor: string;
  letterSpacing?: number;
}

const VARIANT_CONFIGS: Record<AppTextVariant, VariantConfig> = {
  [AppTextVariant.hero]: {
    fontSize: AppFonts.SIZE_HERO,
    defaultWeight: AppFonts.WEIGHT_BOLD,
    defaultColor: AppColors.TEXT_PRIMARY,
    letterSpacing: -0.5
  },
  [AppTextVariant.titleLarge]: {
    fontSize: AppFonts.SIZE_TITLE_LARGE,
    defaultWeight: AppFonts.WEIGHT_BOLD,
    defaultColor: AppColors.TEXT_PRIMARY
  },
  [AppTextVariant.title]: {
    fontSize: AppFonts.SIZE_TITLE,
    defaultWeight: AppFonts.WEIGHT_SEMIBOLD,
    defaultColor: AppColors.TEXT_PRIMARY
  },
  [AppTextVariant.bodyLarge]: {
    fontSize: AppFonts.SIZE_BODY_LARGE,
    defaultWeight: AppFonts.WEIGHT_REGULAR,
    defaultColor: AppColors.TEXT_PRIMARY
  },
  [AppTextVariant.body]: {
    fontSize: AppFonts.SIZE_BODY,
    defaultWeight: AppFonts.WEIGHT_REGULAR,
    defaultColor: AppColors.TEXT_SECONDARY
  },
  [AppTextVariant.caption]: {
    fontSize: AppFonts.SIZE_CAPTION,
    defaultWeight: AppFonts.WEIGHT_REGULAR,
    defaultColor: AppColors.TEXT_TERTIARY
  },
  [AppTextVariant.small]: {
    fontSize: AppFonts.SIZE_SMALL,
    defaultWeight: AppFonts.WEIGHT_REGULAR,
    defaultColor: AppColors.TEXT_TERTIARY
  }
};

@Component
export struct AppText {
  //Required field
  @Require @Prop text: string;
  //Optional fields with defaults
  @Prop variant: AppTextVariant = AppTextVariant.body;
  @Prop color: string | undefined;
  @Prop weight: FontWeight | number | undefined;
  @Prop textAlign: TextAlign = TextAlign.Start;
  @Prop maxLines: number = 0;
  @Prop ellipsis: boolean = false;
  @Prop decoration: TextDecorationType | undefined = undefined;
  @Prop decorationColor: string | undefined = undefined;

  private _getConfig(): VariantConfig {
    return VARIANT_CONFIGS[this.variant] || VARIANT_CONFIGS[AppTextVariant.body];
  }

  private _getFontSize(): number {
    return this._getConfig().fontSize;
  }

  private _getFontWeight(): FontWeight | number {
    return this.weight ?? this._getConfig().defaultWeight;
  }

  private _getFontColor(): string {
    return this.color ?? this._getConfig().defaultColor;
  }

  private _getLetterSpacing(): number | undefined {
    return this._getConfig().letterSpacing;
  }

  build() {
    Text(this.text)
      .fontSize(this._getFontSize())
      .fontWeight(this._getFontWeight())
      .fontColor(this._getFontColor())
      .textAlign(this.textAlign)
      .lineHeight(this._getFontSize() * 1.4)
      .letterSpacing(this._getLetterSpacing())
      .maxLines(this.maxLines > 0 ? this.maxLines : undefined)
      .textOverflow(this.ellipsis ? { overflow: TextOverflow.Ellipsis } : undefined)
      .decoration(this.decoration ? { type: this.decoration, color: this.decorationColor ?? this._getFontColor() } :
        undefined)
  }
}