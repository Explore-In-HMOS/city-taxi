import { AppButton, AppButtonSize, AppButtonType } from '../../common/components/AppButton';
import { AppText, AppTextVariant } from '../../common/components/AppText';
import { AppColors, AppLayout } from '../../common/constants/UIConstants';
import { AddressInfo } from '../../common/models/AddressModel';
import { RideHelper } from '../../common/services/RideHelper';
import { RideViewModel } from '../../common/viewmodel/RideViewModel';

@Builder
export function locationPickingView(vm: RideViewModel, pathStack: NavPathStack) {
  Stack({ alignContent: Alignment.Top }) {
    Column() {
      Row() {
        AppText({
          text: vm.locationPicked ?
            vm.ride.dropOffAddress?.name ?
              vm.ride.dropOffAddress.name :
              vm.ride.dropOffAddress?.address :
            'No Destination',
          variant: AppTextVariant.body,
          color: vm.locationPicked ? AppColors.SUCCESS : AppColors.TEXT_TERTIARY,
          maxLines: 1,
          ellipsis: true
        }).width(120).margin({right: AppLayout.SPACING_SM})

        Blank()

        AppButton({
          type: AppButtonType.iconCircle,
          buttonSize: AppButtonSize.small,
          icon: $r('app.media.location'),
          iconButtonColor: AppColors.CARD_ELEVATED,
          onButtonClick: () => {
            pathStack.pushPathByName('AddressSelectionFromMapPage', null, (popInfo: PopInfo) => {
              const result = popInfo.result as Record<string, AddressInfo>;
              if (result?.address) {
                const address: AddressInfo = result.address;
                vm.setLocationPicked(address);
              }
            });
          }
        })
      }
      .width('100%')
      .padding({ left: AppLayout.SPACING_MD * 3, right: AppLayout.SPACING_MD * 3 })
      .margin({ bottom: AppLayout.SPACING_SM })
      .alignItems(VerticalAlign.Center)

      // Taxi type and Coupon selection dropdowns in a row
      Row({ space: AppLayout.SPACING_SM }) {
        // Taxi type dropdown
        Select(vm.vehicleLabels.map((label) => {
          return { value: label, icon: $r('app.media.startIcon') } as SelectOption;
        }))
          .selected(vm.selectedTaxiType)
          .value(vm.vehicleLabels[vm.selectedTaxiType])
          .font({ size: 12, weight: FontWeight.Medium })
          .fontColor(AppColors.TEXT_PRIMARY)
          .selectedOptionFont({ size: 12, weight: FontWeight.Medium })
          .optionFont({ size: 12 })
          .selectedOptionBgColor(AppColors.CARD_ELEVATED)
          .selectedOptionFontColor(AppColors.TEXT_PRIMARY)
          .optionBgColor(AppColors.CARD)
          .optionFontColor(AppColors.TEXT_SECONDARY)
          .menuAlign(MenuAlignType.CENTER)
          .onSelect((index: number) => {
            vm.setVehicleType(vm.vehicleTypes[index]);
          })
          .height(36)
          .backgroundColor(AppColors.CARD)
          .borderRadius(AppLayout.RADIUS_MD)
          .layoutWeight(1)

        // Coupon dropdown
        Select(vm.couponOptions.map((option) => {
          return { value: option, icon: $r('app.media.startIcon') } as SelectOption;
        }))
          .selected(vm.selectedCouponIndex)
          .value(vm.couponOptions[vm.selectedCouponIndex])
          .font({ size: 12, weight: FontWeight.Medium })
          .fontColor(AppColors.TEXT_PRIMARY)
          .selectedOptionFont({ size: 12, weight: FontWeight.Medium })
          .optionFont({ size: 12 })
          .selectedOptionBgColor(AppColors.CARD_ELEVATED)
          .selectedOptionFontColor(AppColors.TEXT_PRIMARY)
          .optionBgColor(AppColors.CARD)
          .optionFontColor(AppColors.TEXT_SECONDARY)
          .menuAlign(MenuAlignType.CENTER)
          .onSelect((index: number) => {
            vm.setCoupon(index);
          })
          .height(36)
          .backgroundColor(AppColors.CARD)
          .borderRadius(AppLayout.RADIUS_MD)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: AppLayout.SPACING_MD, right: AppLayout.SPACING_MD })
      .margin({ bottom: AppLayout.SPACING_SM })

      // Campaign indicator
      if (vm.activeCampaign && vm.locationPicked) {
        Row() {
          AppText({
            text: '🎯',
            variant: AppTextVariant.caption
          })
          AppText({
            text: `${vm.activeCampaign.title} ${RideHelper.formattedCampaignCountdown(vm.activeCampaign)}`,
            variant: AppTextVariant.caption,
            color: AppColors.ACCENT_PRIMARY,
            weight: FontWeight.Medium
          })
        }
        .width('100%')
        .padding({ left: AppLayout.SPACING_MD, right: AppLayout.SPACING_MD })
        .justifyContent(FlexAlign.Center)
        .backgroundColor(AppColors.CARD_ELEVATED)
        .borderRadius(AppLayout.RADIUS_SM)
        .padding({ top: 4, bottom: 4 })
      }

      Row() {
        AppText({
          text: 'Estimated',
          variant: AppTextVariant.caption,
          color: AppColors.TEXT_SECONDARY
        })

        Blank()

        Row({ space: AppLayout.SPACING_SM }) {
          if (vm.totalDiscount > 0) {
            AppText({
              text: vm.locationPicked ? vm.estimatedPrice : '-- ₺',
              variant: AppTextVariant.caption,
              color: AppColors.TEXT_TERTIARY,
              decoration: TextDecorationType.LineThrough,
              decorationColor: AppColors.TEXT_TERTIARY,
              maxLines: 1,
              ellipsis: true
            })
          }
          // Estimated Price (Discounted or original)
          AppText({
            text: vm.locationPicked ?
              ((vm.totalDiscount > 0) ? vm.discountedPrice : vm.estimatedPrice) :
              '-- ₺',
            variant: AppTextVariant.bodyLarge,
            color: vm.locationPicked ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY,
            weight: FontWeight.Bold,
            maxLines: 1,
            ellipsis: true
          })
        }
      }
      .width('100%')
      .padding({ left: AppLayout.SPACING_XL, right: AppLayout.SPACING_XL })
      .margin({ bottom: AppLayout.SPACING_XS })
      .alignItems(VerticalAlign.Center)

      AppButton({
        text: 'Request Ride',
        type: AppButtonType.arc,
        onButtonClick: () => {
          vm.requestRide();
        }
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)

    // Back button
    AppButton({
      type: AppButtonType.iconCircle,
      buttonSize: AppButtonSize.small,
      icon: $r('app.media.close'),
      iconButtonColor: AppColors.CARD_ELEVATED,
      onButtonClick: () => {
        vm.cancelRide();
      }
    })
      .margin({ top: AppLayout.SPACING_XS })
  }
  .width('100%')
  .height('100%')
}
