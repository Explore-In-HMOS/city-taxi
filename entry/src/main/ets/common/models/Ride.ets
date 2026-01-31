import { AddressInfo } from './AddressModel';
import { DriverInfo, RideInfo, RideStatus } from './RideModel';

@ObservedV2
export class Ride implements RideInfo {
  @Trace id: string = '';
  @Trace status: RideStatus = RideStatus.none;
  @Trace driver: DriverInfo | null = null;
  @Trace pickupAddress: AddressInfo = { latitude: 41.0370, longitude: 28.9857 };
  @Trace etaMinutes: number = 0;
  @Trace driverDistanceKm: number = 0;
  @Trace dropOffAddress?: AddressInfo = { latitude: 0, longitude: 0 };
  @Trace tripDistanceKm?: number = 0;
  @Trace originalTripDistanceKm: number = 0;
  @Trace tripEtaMinutes: number = 0;
  @Trace cost?: number = 0;
  @Trace currency?: string = '';
  // Call UI States
  @Trace isCallUIVisible: boolean = false;
  @Trace callPhase: 'IDLE' | 'RINGING' | 'CONNECTED' | 'ENDED' = 'IDLE';
  @Trace callTitle: string = '';
  @Trace callDurationSec: number = 0;
  @Trace callObserverRegistered: boolean = false;
  @Trace ringingTimeoutId: number | null = null;
  @Trace durationIntervalId: number | null = null;

  // Driver name extraction
  get driverDisplayName(): string {
    if (!this.driver?.name) {
      return '';
    }
    const parts = this.driver.name.split(' ');
    return parts.length >= 2 ? `${parts[0]} ${parts[1].charAt(0)}.` : this.driver.name;
  }

  // Reset ride state
  reset(): void {
    this.id = '';
    this.status = RideStatus.none;
    this.driver = null;
    this.pickupAddress = { latitude: 41.0370, longitude: 28.9857 };
    this.etaMinutes = 0;
    this.driverDistanceKm = 0;
    this.dropOffAddress = { latitude: 0, longitude: 0 };
    this.tripDistanceKm = 0;
    this.originalTripDistanceKm = 0;
    this.tripEtaMinutes = 0;
    this.cost = 0;
    this.currency = '';

    // Reset call-related data
    if (this.ringingTimeoutId !== null) {
      clearTimeout(this.ringingTimeoutId);
      this.ringingTimeoutId = null;
    }
    if (this.durationIntervalId !== null) {
      clearInterval(this.durationIntervalId);
      this.durationIntervalId = null;
    }
    this.isCallUIVisible = false;
    this.callPhase = 'IDLE';
    this.callDurationSec = 0;
    this.callTitle = '';
  }
}