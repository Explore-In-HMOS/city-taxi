import { AppText, AppTextVariant } from '../common/components/AppText';
import { AddressInfo } from '../common/models/AddressModel';
import { appDatabase } from '../database/AppDatabaseImpl';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { AppColors, AppLayout } from '../common/constants/UIConstants';
import { AppButton, AppButtonSize, AppButtonType } from '../common/components/AppButton';

@Builder
export function SavedAddressesPageBuilder() {
  SavedAddressesPage()
}

@ComponentV2
struct SavedAddressesPage {
  pathStack: NavPathStack = new NavPathStack();
  @Local addresses: AddressInfo[] = [];
  @Local isLoading: boolean = true;

  async loadAddresses(): Promise<void> {
    this.isLoading = true;
    try {
      this.addresses = await appDatabase.getSavedDestinations();
    } catch (err) {
      console.error('Failed to load addresses', JSON.stringify(err));
    }
    this.isLoading = false;
  }

  navigateToAddAddress(): void {
    this.pathStack.pushPathByName('AddAddressPage', null, (popInfo: PopInfo) => {
      const result = popInfo.result as Record<string, boolean>;
      if (result && result.addressAdded === true) {
        this.loadAddresses();
      }
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        ArcList({ initialIndex: 1 }) {
          ArcListItem() {
            AppText({ text: 'Saved Addresses', variant: AppTextVariant.title })
          }

          if (this.isLoading) {
            ArcListItem() {
              LoadingProgress().width(AppLayout.ICON_LG).height(AppLayout.ICON_LG).color(AppColors.ACCENT_PRIMARY)
            }
          } else if (this.addresses.length === 0) {
            ArcListItem() {
              this.emptyState();
            }
          } else {
            ForEach(this.addresses, (address: AddressInfo) => {
              ArcListItem() {
                this.addressCard(address);
              }
            }, (address: AddressInfo) => address.name)
          }
        }
        .width('100%')
        .height('100%')

        AppButton({
          text: 'Add Address',
          type: AppButtonType.arc,
          onButtonClick: () => this.navigateToAddAddress()
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.BACKGROUND)
    }
    .parallelGesture(
      PanGesture({ direction: PanDirection.Right })
        .onActionUpdate((event) => {
          const horizontalDistance = event.offsetX;
          if (horizontalDistance > 50 && this.pathStack.getAllPathName().pop() === 'SavedAddressesPage') {
            this.pathStack.pop();
          }
        }))
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.loadAddresses();
    })
  }

  @Builder
  emptyState() {
    Column({ space: AppLayout.SPACING_MD }) {
      AppText({ text: 'No saved addresses', variant: AppTextVariant.bodyLarge })
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  addressCard(address: AddressInfo) {
    Row() {
      Column({ space: AppLayout.SPACING_XS }) {
        AppText({
          text: address.name ?? 'Unnamed location',
          variant: AppTextVariant.bodyLarge,
          maxLines: 1,
          ellipsis: true
        })
        AppText({
          text: address.address ?? 'Unknown address',
          variant: AppTextVariant.caption,
          maxLines: 1,
          ellipsis: true
        })
      }
      .alignItems(HorizontalAlign.Start)

      AppButton({
        type: AppButtonType.iconCircle,
        buttonSize: AppButtonSize.small,
        icon: $r('app.media.location'),
        iconButtonColor: AppColors.CARD_ELEVATED,
        onButtonClick: () => {
          // Navigate to taxi screen with address info
          this.pathStack.pop({ address: address });
        }
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({
      top: AppLayout.SPACING_SM,
      bottom: AppLayout.SPACING_SM,
      left: AppLayout.SPACING_XL,
      right: AppLayout.SPACING_XL
    })
    .margin({ bottom: AppLayout.SPACING_SM })
    .backgroundColor(AppColors.CARD)
    .borderRadius(AppLayout.RADIUS_MD)
  }
}