import { MockApiImpl } from '../../api/MockApiImpl';
import { RideInfo, RideStatus } from '../models/RideModel';
import { RideHelper } from '../services/RideHelper';
import { CallService } from '../services/CallService';
import { AddressInfo } from '../models/AddressModel';
import { PricingService } from '../services/PricingService';
import { CampaignService } from '../services/CampaignService';
import { CouponService } from '../services/CouponService';
import { VehicleType, VEHICLES, QuoteInput, QuoteResult, Campaign, Coupon } from '../models/PricingModel';
import { NotificationService } from '../services/NotificationService';
import { appDatabase } from '../../database/AppDatabaseImpl';
import { JSON } from '@kit.ArkTS';
import { Ride } from '../models/Ride';

@ObservedV2
export class RideViewModel {
  private mockApi: MockApiImpl = new MockApiImpl();
  private etaInterval: number = -1;
  private tripInterval: number = -1;
  private intervalId: number | null = null;
  private notificationShown: boolean = false;
  @Trace ride: Ride = new Ride();
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';
  @Trace locationPicked: boolean = false;
  @Trace selectedTaxiType: number = 0;
  @Trace selectedCoupon: number = 0;
  @Trace pricingResult: QuoteResult | null = null;
  @Trace activeCampaign: Campaign | null = null;
  @Trace driverRating: number = 0;
  // Dynamic data for vehicle types
  readonly vehicleTypes: VehicleType[] = [VehicleType.standard, VehicleType.xl, VehicleType.premium];

  get vehicleLabels(): string[] {
    return this.vehicleTypes.map(type => VEHICLES[type].label);
  }

  // Dynamic data for available coupons
  get availableCoupons(): Coupon[] {
    const now = Date.now();
    const coupons: Coupon[] = [];
    const welcome10 = CouponService.getCouponByCode('WELCOME10', now);
    if (welcome10) {
      coupons.push(welcome10);
    }

    const take20 = CouponService.getCouponByCode('TAKE20', now);
    if (take20) {
      coupons.push(take20);
    }

    const xl15 = CouponService.getCouponByCode('XL15', now);
    if (xl15) {
      coupons.push(xl15);
    }

    return coupons;
  }

  get couponOptions(): string[] {
    return ['No coupon', ...this.availableCoupons.map(c => `${c.title} (${c.code})`)]; // Coupon list options for user
  }

  // Selected coupon
  get selectedCouponIndex(): number {
    if (this.selectedCoupon === 0) {
      return 0;
    }
    const coupon = this.availableCoupons[this.selectedCoupon - 1];
    if (!coupon) {
      return 0;
    }
    const optionTitle = `${coupon.title} (${coupon.code})`;
    return this.couponOptions.findIndex(opt => opt === optionTitle);
  }

  // Estimated price display logic
  get estimatedPrice(): string {
    if (!this.pricingResult || !this.locationPicked) {
      return '-- ₺';
    }
    return `${this.pricingResult.breakdown.total.toFixed(2)} ₺`;
  }

  get discountedPrice(): string {
    return `${((this.pricingResult?.breakdown.total ?? 0) -
      (this.pricingResult?.breakdown.totalDiscount ?? 0)).toFixed(2)} ₺`;
  }

  get totalDiscount(): number {
    return this.pricingResult?.breakdown.totalDiscount ?? 0;
  }

  // Pricing update based on selected inputs (location, coupon, vehicle type)
  private _updatePricing(): void {
    if (!this.locationPicked || !this.ride.dropOffAddress) {
      this.pricingResult = null;
      return;
    }

    const now = Date.now();
    this.activeCampaign = CampaignService.getActiveCampaign(now);

    if (this.activeCampaign && this.intervalId === null) {
      this._startCampaignCountdown();
    }

    let couponCode: string | undefined;
    if (this.selectedCoupon > 0 && this.selectedCoupon - 1 < this.availableCoupons.length) {
      couponCode = this.availableCoupons[this.selectedCoupon - 1].code;
    }

    const quoteInput: QuoteInput = {
      pickupLat: this.ride.pickupAddress.latitude,
      pickupLng: this.ride.pickupAddress.longitude,
      dropOffLat: this.ride.dropOffAddress.latitude,
      dropOffLng: this.ride.dropOffAddress.longitude,
      vehicleType: this.selectedVehicleType,
      couponCode: couponCode,
      discountChoice: 'AUTO'
    };
    this.pricingResult = PricingService.calculate(quoteInput, now);
  }

  private _startCampaignCountdown(): void {
    if (this.intervalId !== null) {
      return;
    }
    this.intervalId = setInterval(() => {
      this._updatePricing();
    }, 1000);
  }

  // ---------- COMPUTED VALUES ----------
  @Computed
  get statusColor(): string {
    return RideHelper.getStatusColor(this.ride.status);
  }

  @Computed
  get statusText(): string {
    return RideHelper.getStatusText(this.ride.status);
  }

  @Computed
  get hasActiveRide(): boolean {
    return this.ride.status !== RideStatus.none &&
      this.ride.status !== RideStatus.locationPicking &&
      this.ride.status !== RideStatus.completed &&
      this.ride.status !== RideStatus.cancelled;
  }

  @Computed
  get canCancel(): boolean {
    return this.ride.status === RideStatus.searching ||
      this.ride.status === RideStatus.locationPicking ||
      this.ride.status === RideStatus.driverArriving ||
      this.ride.status === RideStatus.inProgress;
  }

  @Computed // Check if driver info should be shown
  get showDriverInfo(): boolean {
    return (this.ride.status === RideStatus.driverArriving ||
      this.ride.status === RideStatus.inProgress) &&
      this.ride.driver !== null;
  }

  @Computed // Check if ETA should be shown
  get showEta(): boolean {
    return this.ride.status === RideStatus.driverArriving &&
      this.ride.etaMinutes > 0;
  }

  @Computed
  get showTripEta(): boolean {
    return this.ride.status === RideStatus.inProgress &&
    this.locationPicked &&
      this.ride.tripEtaMinutes > 0;
  }

  @Computed
  get hasDestination(): boolean {
    return this.locationPicked;
  }

  // ---------- ACTIONS ----------
  setLocationPicking() {
    if (this.hasActiveRide) {
      return;
    }
    this.ride.status = RideStatus.locationPicking;
    this.locationPicked = false;
    this.selectedTaxiType = 0;
    this.selectedCoupon = 0;
    this.pricingResult = null;
    this.activeCampaign = null;
  }

  setLocationPicked(picked: AddressInfo): void {
    this.ride.status = RideStatus.locationPicking;
    this.locationPicked = true;
    this.ride.dropOffAddress = picked;
    this._updatePricing();
  }

  setTaxiType(index: number): void {
    this.selectedTaxiType = index;
    this._updatePricing();
  }

  setVehicleType(vehicleType: VehicleType): void {
    const index = this.vehicleTypes.indexOf(vehicleType);
    if (index !== -1) {
      this.selectedTaxiType = index;
      this._updatePricing();
    }
  }

  get selectedVehicleType(): VehicleType {
    return this.vehicleTypes[this.selectedTaxiType] || VehicleType.standard;
  }

  setCoupon(index: number): void {
    this.selectedCoupon = index;
    this._updatePricing();
  }

  // Making the ride request
  async requestRide(): Promise<void> {
    if (this.ride.status !== RideStatus.locationPicking) {
      return;
    }

    if (!this.locationPicked || !this.ride.dropOffAddress) {
      this.errorMessage = 'Please select a destination';
      return;
    }

    if (!this.pricingResult || this.pricingResult.errors.length > 0) {
      this.errorMessage = this.pricingResult?.errors.join(', ') ?? 'Pricing error';
      return;
    }

    this.ride.id = `RIDE=${Date.now()}`;
    this.ride.status = RideStatus.searching;
    this.ride.pickupAddress.address = 'Current Location';
    this.ride.pickupAddress.latitude = this.ride.pickupAddress.latitude || 41.0370;
    this.ride.pickupAddress.longitude = this.ride.pickupAddress.longitude || 28.9857;
    // Set pricing info
    this.ride.cost = this.pricingResult.breakdown.total;
    this.ride.currency = this.pricingResult.breakdown.currency;
    this.ride.tripDistanceKm = this.pricingResult.breakdown.distanceKm;

    try {
      const results = await Promise.all([
        this.mockApi.fetchDriver(),
        this.mockApi.fetchDriverDistance()
      ]);
      this.ride.driver = results[0];
      this.ride.driverDistanceKm = results[1];
      this.ride.etaMinutes = RideHelper.calculateEta(results[1]);
      this.ride.status = RideStatus.driverArriving;
      this._startEtaCountdown();
    } catch (e) {
      this.errorMessage = 'Failed to find driver';
      this.ride.reset();
    }
  }

  // Cancel the ride
  cancelRide(): void {
    if (!this.canCancel) {
      this.errorMessage = 'Cannot cancel ride at this stage';
      return;
    }
    this._stopEtaCountdown();
    this.ride.reset();
  }

  callDriver(): void {
    CallService.callDriver(this.ride, (msg: string) => {
      this.errorMessage = msg;
    });
  }

  endCall(): void {
    CallService.endCall(this.ride);
  }

  private _startEtaCountdown(): void {
    this._stopEtaCountdown();
    this.etaInterval = setInterval(() => {
      if (this.ride.etaMinutes > 1 && this.ride.status === RideStatus.driverArriving) {
        this.ride.etaMinutes--;
        //If going from 2 minutes -> 1min, show notification
        if (this.ride.etaMinutes <= 2 && this.ride.status === RideStatus.driverArriving && !this.notificationShown) {
          NotificationService.notifyDriverArrivingOneMinute(
            this.ride.id,
            this.ride.driverDisplayName || (this.ride.driver?.name ?? 'Driver')
          );
          this.notificationShown = true;
        }
      } else if (this.ride.etaMinutes <= 1 && this.ride.status === RideStatus.driverArriving) {
        this.ride.etaMinutes = 0;
        this.ride.status = RideStatus.inProgress;
        this._stopEtaCountdown();
        this._startTripCountdown();
      }
    }, 60000);
  }

  private _stopEtaCountdown(): void {
    if (this.etaInterval !== -1) {
      clearInterval(this.etaInterval);
      this.etaInterval = -1;
    }
  }

  private _startTripCountdown(): void {
    this._stopTripCountdown();

    if (this.ride.dropOffAddress) {
      const distance = RideHelper.calculateDistance(
        this.ride.pickupAddress.latitude,
        this.ride.pickupAddress.longitude,
        this.ride.dropOffAddress.latitude,
        this.ride.dropOffAddress.longitude
      );
      this.ride.tripDistanceKm = distance;
      this.ride.originalTripDistanceKm = distance;
      this.ride.tripEtaMinutes = RideHelper.calculateEta(distance);
    } else {
      // No destination set, use mock 1min
      this.ride.tripDistanceKm = 0;
      this.ride.tripEtaMinutes = 1;
    }

    // Calculate decrement per tick
    const kmPerTick = (this.ride.tripDistanceKm ?? 0) / ((this.ride.tripEtaMinutes || 1) * 6);

    this.tripInterval = setInterval(() => {
      if (this.ride.status !== RideStatus.inProgress) {
        this._stopTripCountdown();
        return;
      }

      // Decrement distance
      if (this.ride.tripDistanceKm && this.ride.tripDistanceKm > 0) {
        this.ride.tripDistanceKm = Number(Math.max(this.ride.tripDistanceKm - kmPerTick, 0).toFixed(1));
      }

      //Decrement ETA
      if (this.ride.tripDistanceKm !== undefined && this.ride.tripDistanceKm <= 0) {
        this.ride.tripEtaMinutes = 0;
        this.ride.tripDistanceKm = 0;
        this.ride.status = RideStatus.completed;
        this._stopTripCountdown();
        this._saveCompletedTrip(this.ride);
      } else {
        this.ride.tripEtaMinutes = RideHelper.calculateEta(this.ride.tripDistanceKm ?? 0);
      }
    }, 10000);
  }

  private _stopTripCountdown(): void {
    if (this.tripInterval !== -1) {
      clearInterval(this.tripInterval);
      this.tripInterval = -1;
    }
  }

  async rateDriver(rating: number): Promise<void> {
    this.driverRating = rating;
    try {
      await this.mockApi.submitDriverRating(this.ride.id, rating);
    } catch (e) {
      console.error('Failed to submit rating', JSON.stringify(e));
    }
  }

  finishRide(): void {
    this._stopEtaCountdown();
    this._stopTripCountdown();
    this.driverRating = 0;
    this.ride.reset();
  }

  private async _saveCompletedTrip(trip: RideInfo): Promise<void> {
    try {
      trip.tripDistanceKm = this.ride.originalTripDistanceKm;
      trip.status = RideStatus.completed;
      await appDatabase.insertOldTrip(trip);
      console.info('Saved completed trip to DB');
    } catch (e) {
      console.error('Failed to save completed trip to DB:', JSON.stringify(e));
    }
  }
}