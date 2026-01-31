import { AppButton, AppButtonType } from '../../common/components/AppButton';
import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppColors, AppLayout } from '../../common/constants/UIConstants';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';
import { statusIndicator } from './StatusIndicator';
import { vibrator } from '@kit.SensorServiceKit';

export function getRatingText(rating: number): string {
  switch (rating) {
    case 1:
      return 'Poor';
    case 2:
      return 'Fair';
    case 3:
      return 'Good';
    case 4:
      return 'Very Good';
    case 5:
      return 'Excellent!';
    default:
      return 'Rate your driver';
  }
}

export function vibrate(): void {
  try {
  vibrator.startVibration({
  type: 'time',
  duration: 500
}, {
  id: 0,
  usage: 'physicalFeedback'
}, (error: BusinessError) => {
  if (error) {
    console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
    return;
  }
  console.info('Succeed in starting vibration');
});
} catch (err) {
  const e: BusinessError = err as BusinessError;
  console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
}
}

@Builder
export function completedView(vm: RideViewModel) {
  Column() {
    statusIndicator(vm.statusText, vm.statusColor, AppTextVariant.body, AppLayout.SPACING_LG);

    Column({ space: AppLayout.SPACING_MD }) {
      //Title
      AppText({ text: 'Rate your driver', variant: AppTextVariant.title })
      //Driver Name
      if (vm.ride.driver) {
        AppText({ text: vm.ride.driverDisplayName, variant: AppTextVariant.body })
      }
      //Rating Component
      Rating({ rating: vm.driverRating, indicator: false })
        .stars(5)
        .stepSize(1)
        .starStyle({
          backgroundUri: '',
          foregroundUri: '',
          secondaryUri: ''
        })
        .onChange((value: number) => {
          vm.rateDriver(value);
        })
        .width(180)
        .height(36)
      //Rating Text
      AppText({
        text: getRatingText(vm.driverRating),
        variant: AppTextVariant.caption,
        color: vm.driverRating === 0 ? AppColors.TRANSPARENT : AppColors.ACCENT_PRIMARY
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)

    AppButton({
      text: 'Done',
      type: AppButtonType.arc,
      onButtonClick: () => {
        vm.finishRide();
      }
    })
  }
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .onAppear(() => {
    vibrate();
  })
}
