import { AppButton, AppButtonType } from '../../common/components/AppButton';
import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppColors, AppLayout } from '../../common/constants/UIConstants';
import { RideStatus } from '../../common/models/RideModel';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';
import { AddAddressPageBuilder } from '../AddAddressPage';
import { AddressSearchPageBuilder } from '../AddressSearchPage';
import { AddressSelectionFromMapPageBuilder } from '../AddressSelectionFromMapPage';
import { OldTripsPageBuilder } from '../OldTripsPage';
import { SavedAddressesPageBuilder } from '../SavedAddressesPage';
import { noRideView } from './NoRideView';
import { locationPickingView } from './LocationPickingView';
import { findingDriverView } from './FindingDriverView';
import { driverArrivingView } from './DriverArrivingView';
import { inProgressView } from './InProgressView';
import { completedView } from './CompletedView';
import { RideHelper } from '../../common/services/RideHelper';

@ComponentV2
export struct TaxiHome {
  @Local vm: RideViewModel = new RideViewModel();
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string) {
    if (name === 'AddressSelectionFromMapPage') {
      AddressSelectionFromMapPageBuilder();
    } else if (name === 'SavedAddressesPage') {
      SavedAddressesPageBuilder();
    } else if (name === 'AddAddressPage') {
      AddAddressPageBuilder();
    } else if (name === 'AddressSearchPage') {
      AddressSearchPageBuilder();
    } else if (name === 'OldTripsPage') {
      OldTripsPageBuilder();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Stack() {
        Column() {
          if (this.vm.ride.status === RideStatus.none) {
            noRideView(this.vm, this.pathStack);
          } else if (this.vm.ride.status === RideStatus.locationPicking) {
            locationPickingView(this.vm, this.pathStack);
          } else if (this.vm.ride.status === RideStatus.searching) {
            findingDriverView(this.vm);
          } else if (this.vm.ride.status === RideStatus.driverArriving) {
            driverArrivingView(this.vm, () => this._showCancelDialog());
          } else if (this.vm.ride.status === RideStatus.inProgress) {
            inProgressView(this.vm, () => this._showCancelDialog());
          } else if (this.vm.ride.status === RideStatus.completed) {
            completedView(this.vm);
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(AppColors.BACKGROUND)
        .justifyContent(FlexAlign.Center)

        if (this.vm.ride.isCallUIVisible) {
          this.callOverlay();
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
  }

  @Builder
  callOverlay() {
    Column({ space: AppLayout.SPACING_MD }) {

      AppText({
        text: this.vm.ride.callPhase === 'CONNECTED' ?
          `${this.vm.ride.driverDisplayName} connected` :
          `Calling ${this.vm.ride.driverDisplayName || 'driver'}...`,
        variant: AppTextVariant.bodyLarge,
        color: AppColors.TEXT_PRIMARY
      })

      AppText({
        text: `${this.vm.ride.driver?.vehicleModel} • ${this.vm.ride.driver?.vehiclePlate}`,
        variant: AppTextVariant.caption,
        color: AppColors.TEXT_SECONDARY
      })

      if (this.vm.ride.callPhase === 'RINGING') {
        AppText({
          text: 'Ringing...',
          variant: AppTextVariant.caption,
          color: AppColors.TEXT_PRIMARY
        })
      }

      if (this.vm.ride.callPhase === 'CONNECTED') {
        AppText({
          text: RideHelper.callDurationText(this.vm.ride.callDurationSec),
          variant: AppTextVariant.hero,
          color: AppColors.ACCENT_PRIMARY
        })
      }

      if (this.vm.ride.callPhase === 'ENDED') {
        AppText({
          text: 'Call ended',
          variant: AppTextVariant.caption,
          color: AppColors.TEXT_SECONDARY
        })
      }

      if (this.vm.ride.callPhase !== 'ENDED') {
        AppButton({
          type: AppButtonType.iconCircle,
          icon: $r('app.media.close'),
          iconButtonColor: AppColors.ERROR,
          onButtonClick: () => this.vm.endCall()
        })
          .margin({ top: AppLayout.SPACING_SM })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F0000000')
  }

  private _showCancelDialog(): void {
    this.getUIContext().showAlertDialog({
      title: 'Cancel Ride',
      message: 'Are you sure you want to cancel this ride?',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: 'Yes',
        fontColor: AppColors.ERROR,
        action: () => {
          this.vm.cancelRide();
        }
      },
      secondaryButton: {
        value: 'No',
        fontColor: AppColors.TEXT_PRIMARY,
        action: () => {
          // No additional action
        }
      }
    });
  }
}
