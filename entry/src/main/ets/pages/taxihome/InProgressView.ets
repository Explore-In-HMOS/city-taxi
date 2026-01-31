import { AppLottie } from '../../common/components/AppLottie';
import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppColors, AppLayout } from '../../common/constants/UIConstants';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';
import { driverInfoPanel } from './DriverInfoPanel';
import { statusIndicator } from './StatusIndicator';

@Builder
export function inProgressView(vm: RideViewModel, onCancelClick: ()=>void) {
  Column() {
    statusIndicator(vm.statusText, vm.statusColor, AppTextVariant.caption, AppLayout.SPACING_MD);

    if (vm.showTripEta) {
      Row({ space: AppLayout.SPACING_SM }) {
        Column({ space: 2 }) {
          AppText({
            text: `${vm.ride.tripEtaMinutes}`,
            variant: AppTextVariant.hero,
            color: AppColors.SUCCESS
          })
          AppText({
            text: 'min',
            variant: AppTextVariant.caption
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Divider().vertical(true).height(40).color(AppColors.TEXT_TERTIARY)

        Column({ space: 2 }) {
          AppText({
            text: `${vm.ride.tripDistanceKm}`,
            variant: AppTextVariant.hero,
            color: AppColors.ACCENT_PRIMARY
          })
          AppText({
            text: 'km',
            variant: AppTextVariant.caption
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .padding({ left: AppLayout.SPACING_LG, right: AppLayout.SPACING_LG })
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      // In progress state
      Column() {
        AppLottie({
          animationPath: 'rawfile/taxi.json',
          loop: true
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }

    // Bottom section
    if (vm.ride.driver !== null && !vm.ride.isCallUIVisible) {
      driverInfoPanel(vm, onCancelClick);
    }
  }
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
}
