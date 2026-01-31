import { AppButton, AppButtonType } from '../../common/components/AppButton';
import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppColors, AppLayout } from '../../common/constants/UIConstants';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';

@Builder
export function driverInfoPanel(vm: RideViewModel, onCancelClick: ()=>void) {
  Column({ space: AppLayout.SPACING_SM }) {
    Row({ space: AppLayout.SPACING_SM }) {
      AppText({ text: vm.ride.driverDisplayName, variant: AppTextVariant.body })
      AppText({ text: '-', variant: AppTextVariant.body })
      AppText({ text: vm.ride.driver?.vehiclePlate ?? '', variant: AppTextVariant.caption })
    }.justifyContent(FlexAlign.Center)

    // Action Buttons
    Row({ space: AppLayout.SPACING_MD }) {
      // Call
      AppButton({
        type: AppButtonType.iconCircle,
        icon: $r('app.media.call'),
        iconButtonColor: AppColors.ACCENT_PRIMARY,
        onButtonClick: () => {
          vm.callDriver();
        }
      })

      // Cancel
      if (vm.canCancel) {
        AppButton({
          type: AppButtonType.iconCircle,
          icon: $r('app.media.close'),
          iconButtonColor: AppColors.CARD_ELEVATED,
          onButtonClick: onCancelClick
        })
      }
    }
    .justifyContent(FlexAlign.Center)
  }
  .width('100%')
  .padding({
    left: AppLayout.SPACING_MD,
    right: AppLayout.SPACING_MD,
    bottom: AppLayout.SPACING_LG,
    top: AppLayout.SPACING_MD
  })
  .backgroundColor(AppColors.CARD)
  .alignItems(HorizontalAlign.Center)
}
