import { AppButton, AppButtonSize, AppButtonType } from '../../common/components/AppButton';
import { AppLottie } from '../../common/components/AppLottie';
import { AppLayout } from '../../common/constants/UIConstants';
import { AddressInfo } from '../../common/models/AddressModel';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';

@Builder
export function noRideView(vm: RideViewModel, pathStack: NavPathStack) {
  Column() {
    Blank().layoutWeight(1)

    AppLottie({
      animationPath: 'rawfile/taxi.json',
      loop: false,
      staticFrame: 0
    })

    Row() {
      AppButton({
        type: AppButtonType.iconCircle,
        icon: $r('app.media.history'),
        buttonSize: AppButtonSize.small,
        onButtonClick: () => {
          pathStack.pushPathByName('OldTripsPage', null);
        }
      })
      AppButton({
        text: 'Saved Addresses',
        type: AppButtonType.secondary,
        buttonSize: AppButtonSize.small,
        onButtonClick: () => {
          pathStack.pushPathByName('SavedAddressesPage', null, (popInfo: PopInfo) => {
            const result = popInfo.result as Record<string, AddressInfo>;
            if (result?.address) {
              const address: AddressInfo = result.address;
              vm.setLocationPicked(address);
            }
          });
        }
      }).margin({ left: AppLayout.SPACING_XS })
    }.alignItems(VerticalAlign.Center).margin({ bottom: AppLayout.SPACING_XS })

    AppButton({
      text: 'Call Taxi',
      type: AppButtonType.arc,
      onButtonClick: () => {
        vm.setLocationPicking();
      }
    })
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}
