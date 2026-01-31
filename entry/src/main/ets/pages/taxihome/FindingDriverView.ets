import { AppButton, AppButtonType } from '../../common/components/AppButton';
import { AppTextVariant } from '../../common/components/AppText';
import { AppLayout } from '../../common/constants/UIConstants';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';
import { statusIndicator } from './StatusIndicator';

@Builder
export function findingDriverView(vm: RideViewModel) {
  Column() {
    Column({ space: AppLayout.SPACING_SM }) {
      statusIndicator(vm.statusText, vm.statusColor, AppTextVariant.body);
      AppButton({
        type: AppButtonType.iconCircle,
        icon: $r('app.media.close'),
        onButtonClick: () => {
          vm.cancelRide();
        }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
}
