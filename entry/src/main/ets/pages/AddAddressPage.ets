import { AppText, AppTextVariant } from '../common/components/AppText';
import { AddressInfo } from '../common/models/AddressModel';
import { appDatabase } from '../database/AppDatabaseImpl';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';
import { AppColors, AppFonts, AppLayout } from '../common/constants/UIConstants';
import { AppButton, AppButtonSize, AppButtonType } from '../common/components/AppButton';
import { JSON } from '@kit.ArkTS';

@Builder
export function AddAddressPageBuilder() {
  AddAddressPage()
}

@ComponentV2
struct AddAddressPage {
  pathStack: NavPathStack = new NavPathStack();
  @Local name: string = '';
  @Local address: string = '';
  @Local pickedLocation: AddressInfo | null = null;
  @Local isSaving: boolean = false;
  @Local errorMessage: string = '';

  private _isFormValid(): boolean {
    return this.pickedLocation !== null;
  }

  private _locationDisplayText(): string {
    if (!this.pickedLocation) {
      return 'No location selected';
    }
    return this.pickedLocation.address ?? '';
  }

  private _pickLocation(): void {
    this.pathStack.pushPathByName('AddressSelectionFromMapPage', null, (popInfo: PopInfo) => {
      const result = popInfo.result as Record<string, AddressInfo>;
      if (result?.address) {
        this.pickedLocation = result?.address;
      }
    });
  }

  async saveAddress(): Promise<void> {
    if (!this._isFormValid() || !this.pickedLocation) {
      this.errorMessage = 'Please pick a location';
      return;
    }

    this.isSaving = true;
    this.errorMessage = '';

    try {
      const addressInfo: AddressInfo = {
        name: this.name.trim() || undefined,
        address: this.address.trim() ?? this.pickedLocation.address ?? undefined,
        latitude: this.pickedLocation.latitude,
        longitude: this.pickedLocation.longitude,
        createdAt: new Date()
      };

      const rowId = await appDatabase.insertSavedDestination(addressInfo);
      if (rowId > 0) {
        this.pathStack.pop({ addressAdded: true });
      } else {
        this.errorMessage = 'Failed to save address';
      }
    } catch (err) {
      console.error('Failed to save address:', JSON.stringify(err));
      this.errorMessage = 'An error occurred';
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        ArcList({ initialIndex: 1 }) {
          ArcListItem() {
            AppText({ text: 'Add New Address', variant: AppTextVariant.title })
          }

          ArcListItem() {
            this.inputField('Name(Optional)', 'eg., Home, Work', this.name, (v: string) => {
              this.name = v;
            });
          };

          ArcListItem() {
            this.inputField('Address(Optional)', 'Street Address', this.address, (v: string) => {
              this.address = v;
            });
          };

          ArcListItem() {
            this.locationPickerField();
          };

          if (this.errorMessage) {
            ArcListItem() {
              AppText({ text: this.errorMessage, variant: AppTextVariant.caption, color: AppColors.ERROR })
            };
          }
        }
        .width('100%')
        .height('100%')

        AppButton({
          text: 'Save Address',
          type: AppButtonType.arc,
          loading: this.isSaving,
          disabled: !this._isFormValid(),
          onButtonClick: () => this.saveAddress()
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
          if (horizontalDistance > 50 && this.pathStack.getAllPathName().pop() === 'AddAddressPage') {
            this.pathStack.pop();
          }
        }))
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  @Builder
  locationPickerField() {
    Column({ space: AppLayout.SPACING_XS }) {
      AppText({ text: 'Location', variant: AppTextVariant.caption })

      Row() {
        Column({ space: 2 }) {
          AppText({
            text: this.pickedLocation ? 'Location Selected' : 'Tap to pick a location',
            variant: AppTextVariant.body
          })
          if (this.pickedLocation) {
            AppText({
              text: this._locationDisplayText(),
              variant: AppTextVariant.caption
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        AppButton({
          type: AppButtonType.iconCircle,
          buttonSize: AppButtonSize.small,
          icon: $r('app.media.location'),
          iconButtonColor: this.pickedLocation ? AppColors.SUCCESS : AppColors.ACCENT_PRIMARY,
          onButtonClick: () => this._pickLocation()
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor(AppColors.CARD)
      .borderRadius(AppLayout.RADIUS_MD)
      .padding({ left: AppLayout.SPACING_MD, right: AppLayout.SPACING_MD })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: AppLayout.SPACING_LG, right: AppLayout.SPACING_LG })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  inputField(label: string, placeholder: string, value: string, onChange: (value: string) => void,
    isNumber: boolean = false) {
    Column({ space: AppLayout.SPACING_XS }) {
      AppText({ text: label, variant: AppTextVariant.caption })

      TextInput({ placeholder: placeholder, text: value })
        .width('100%')
        .height(44)
        .fontSize(AppFonts.SIZE_BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .placeholderColor(AppColors.TEXT_TERTIARY)
        .backgroundColor(AppColors.CARD)
        .borderRadius(AppLayout.RADIUS_MD)
        .padding({ left: AppLayout.SPACING_MD, right: AppLayout.SPACING_MD })
        .type(isNumber ? InputType.NUMBER_DECIMAL : InputType.Normal)
        .onChange(onChange)
    }
    .width('100%')
    .padding({ left: AppLayout.SPACING_LG, right: AppLayout.SPACING_LG })
    .alignItems(HorizontalAlign.Start)
  }
}