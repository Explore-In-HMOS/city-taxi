import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppLayout } from '../../common/constants/UIConstants';

@Builder
export function statusIndicator(
  text: string = this.vm.statusText,
  color: string,
  variant: AppTextVariant = AppTextVariant.caption,
  marginTop: number = 0
) {
  Row({ space: AppLayout.SPACING_SM }) {
    Circle({ width: AppLayout.STATUS_DOT_SM, height: AppLayout.STATUS_DOT_SM }).fill(color)
    AppText({ text: text, variant: variant })
  }.margin({ top: marginTop })
}