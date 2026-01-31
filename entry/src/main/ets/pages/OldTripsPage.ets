import { RideInfo } from '../common/models/RideModel';
import { appDatabase } from '../database/AppDatabaseImpl';
import { AppColors, AppLayout } from '../common/constants/UIConstants';
import { AppText, AppTextVariant } from '../common/components/AppText';
import { ArcList, ArcListItem, ArcListAttribute } from '@ohos.arkui.ArcList';

@Builder
export function OldTripsPageBuilder() {
  OldTripsPage()
}

@ComponentV2
struct OldTripsPage {
  pathStack: NavPathStack = new NavPathStack();
  @Local trips: RideInfo[] = [];
  @Local isLoading: boolean = true;

  async loadTrips(): Promise<void> {
    this.isLoading = true;
    try {
      this.trips = await appDatabase.getOldTrips();
    } catch (e) {
    }
    this.isLoading = false;
  }

  formatDate(date?: Date): string {
    if (!date) {
      return 'Unknown date';
    }
    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const year = date.getFullYear();
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${day}/${month}/${year} ${hours}:${minutes}`;
  }

  formatCost(cost?: number, currency?: string): string {
    if (cost === undefined) {
      return '';
    }
    return `${cost.toFixed(2)} ${currency ?? 'TL'}`;
  }

  build() {
    NavDestination() {
      ArcList({ initialIndex: 1 }) {
        ArcListItem() {
          AppText({ text: 'Trip History', variant: AppTextVariant.title })
        }

        if (this.isLoading) {
          ArcListItem() {
            LoadingProgress().width(40).height(40).color(AppColors.ACCENT_PRIMARY)
          };
        } else if (this.trips.length === 0) {
          ArcListItem() {
            this.emptyState();
          };
        } else {
          ForEach(this.trips, (trip: RideInfo) => {
            ArcListItem() {
              this.tripCard(trip);
            };
          }, (trip: RideInfo) => trip.id)
        }
      }
      .width('100%')
      .height('100%')
    }
    .parallelGesture(
      PanGesture({ direction: PanDirection.Right })
        .onActionUpdate((event) => {
          const horizontalDistance = event.offsetX;
          if (horizontalDistance > 50 && this.pathStack.getAllPathName().pop() === 'OldTripsPage') {
            this.pathStack.pop();
          }
        }))
    .hideTitleBar(true)
    .backgroundColor(AppColors.BACKGROUND)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.loadTrips();
    })
  }

  @Builder
  emptyState() {
    Column({ space: AppLayout.SPACING_MD }) {
      AppText({ text: 'No past trips', variant: AppTextVariant.bodyLarge })
      AppText({ text: 'Your completed trips will appear here', variant: AppTextVariant.caption })
    }
    .width('80%')
    .height(120)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tripCard(trip: RideInfo) {
    Column({ space: AppLayout.SPACING_XS }) {
      // Date and cost
      Row() {
        AppText({
          text: this.formatDate(trip.completedAt),
          variant: AppTextVariant.caption
        })
        if (trip.cost !== undefined) {
          AppText({
            text: this.formatCost(trip.cost, trip.currency),
            variant: AppTextVariant.caption,
            color: AppColors.ACCENT_PRIMARY
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // Pickup Location
      Row({ space: AppLayout.SPACING_XS }) {
        Circle({ width: AppLayout.STATUS_DOT_SM, height: AppLayout.STATUS_DOT_SM }).fill(AppColors.ACCENT_PRIMARY)
        AppText({
          text: trip.pickupAddress.address,
          variant: AppTextVariant.caption,
          color: AppColors.TEXT_PRIMARY,
          maxLines: 1,
          ellipsis: true
        }).layoutWeight(1)
      }
      .width('100%')

      // DropOff Location
      Row({ space: AppLayout.SPACING_XS }) {
        Circle({ width: AppLayout.STATUS_DOT_SM, height: AppLayout.STATUS_DOT_SM }).fill(AppColors.SUCCESS)
        AppText({
          text: trip.dropOffAddress?.address ?? 'Unknown Destination',
          variant: AppTextVariant.caption,
          color: AppColors.TEXT_PRIMARY,
          maxLines: 1,
          ellipsis: true
        }).layoutWeight(1)
      }
      .width('100%')

      // Driver Info
      if (trip.driver) {
        Row({ space: AppLayout.SPACING_SM }) {
          AppText({
            text: trip.driver.name,
            variant: AppTextVariant.caption,
            color: AppColors.TEXT_SECONDARY,
            maxLines: 1,
            ellipsis: true
          })
          AppText({
            text: `⭐ ${trip.driver.rating.toFixed(1)}`,
            variant: AppTextVariant.caption,
            color: AppColors.TEXT_TERTIARY,
            maxLines: 1,
            ellipsis: true
          })
          AppText({
            text: trip.driver.vehiclePlate,
            variant: AppTextVariant.caption,
            color: AppColors.TEXT_TERTIARY,
            maxLines: 1,
            ellipsis: true
          })
        }
        .width('100%')
      }
    }
    .width('90%')
    .padding(AppLayout.SPACING_MD)
    .margin({ bottom: AppLayout.SPACING_SM })
    .backgroundColor(AppColors.CARD)
    .borderRadius(AppLayout.RADIUS_MD)
  }
}