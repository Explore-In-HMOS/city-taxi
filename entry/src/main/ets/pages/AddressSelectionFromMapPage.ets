import { MapComponent } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import { AppButton, AppButtonType, } from '../common/components/AppButton';
import { AppColors } from '../common/constants/UIConstants';
import { BubbleText } from '../common/components/BubbleText';
import { AddressInfo } from '../common/models/AddressModel';
import { AddressSelectionFromMap } from './map/AddressSelectionFromMap';

@Builder
export function AddressSelectionFromMapPageBuilder() {
  AddressSelectionFromMapPage()
}

@Component
struct AddressSelectionFromMapPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State currentAddress: AddressInfo = { address: '...', latitude: 0, longitude: 0 };
  private mapLogic?: AddressSelectionFromMap;

  aboutToAppear(): void {
    if (this.mapLogic) {
      return;
    }
    this.mapLogic = new AddressSelectionFromMap({
      getCurrentAddress: () => this.currentAddress,
      setCurrentAddress: (address: AddressInfo) => {
        this.currentAddress = address;
      },
      getHostContext: () => this.getUIContext().getHostContext() as common.UIAbilityContext
    });
  }

  onPageShow(): void {
    this.mapLogic?.onPageShow();
  }

  onPageHide(): void {
    this.mapLogic?.onPageHide();
  }

  aboutToDisappear(): void {
    this.mapLogic?.aboutToDisappear();
  }

  @Builder
  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {

        Stack({ alignContent: Alignment.Bottom }) {
          Stack({ alignContent: Alignment.Center }) {

            MapComponent({ mapOptions: this.mapLogic?.mapOptions, mapCallback: this.mapLogic?.mapCallback })
              .width('100%')
              .height('100%')
              .padding({ 'bottom': '15%' })

            Stack() {
              BubbleText({ text: this.currentAddress.address })
            }
            .width(125)
            .hitTestBehavior(HitTestMode.Transparent)

          }
          .width('100%')
          .height('100%');

          AppButton({
            type: AppButtonType.arc,
            text: 'Select',
            iconButtonColor: AppColors.CARD_ELEVATED,
            disabled: this.currentAddress.address === '...',
            onButtonClick: () => {
              const center = this.mapLogic?.getCenterLatLng();
              if (!center) {
                console.warn(this.mapLogic?.TAG ?? 'MapKit', 'Cannot select location: map center is unknown.');
                return;
              }

              const selected: AddressInfo = {
                latitude: center.latitude,
                longitude: center.longitude,
                address: this.currentAddress.address,
                name: this.currentAddress.name
              };
              this.pathStack.pop({ address: selected });
            }
          })
        }
        .width('100%')
        .height('100%');

        Row({ space: 4 }) {
          AppButton({
            type: AppButtonType.iconCircle,
            icon: $r('app.media.close'),
            iconButtonColor: AppColors.CARD_ELEVATED,
            onButtonClick: () => {
              this.pathStack.pop();
            }
          })
          AppButton({
            type: AppButtonType.iconCircle,
            icon: $r('app.media.search'),
            iconButtonColor: AppColors.CARD_ELEVATED,
            onButtonClick: () => {
              this.pathStack.pushPathByName('AddressSearchPage', this.currentAddress, (popInfo: PopInfo) => {
                const result = popInfo.result as Record<string, AddressInfo>;
                if (result?.address) {
                  const selected = result.address;
                  this.mapLogic?.applySelectedAddress(selected);
                }
              });
            }
          })
        }
        .padding({ top: 8 })
      }
      .width('100%')
      .height('100%');
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .backgroundColor(Color.White)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}
