import { AddressInfo } from './AddressModel';

export enum RideStatus {
  none = 'none',
  locationPicking = 'location_picking',
  searching = 'searching',
  driverArriving = 'driver_arriving',
  inProgress = 'in_progress',
  completed = 'completed',
  cancelled = 'cancelled'
}

export interface DriverInfo {
  name: string;
  rating: number;
  vehiclePlate: string;
  vehicleModel: string;
  vehicleColor: string;
  photoUrl?: string;
  phoneNumber?: string;
}

export interface RideInfo {
  id: string;
  status: RideStatus;
  driver?: DriverInfo | null;
  pickupAddress: AddressInfo;
  driverDistanceKm: number;
  dropOffAddress?: AddressInfo | null; // Optional, if destination set
  tripDistanceKm?: number; // km - Optional, if destination set
  cost?: number; // Optional, if destination set
  currency?: string; // Optional, if destination set
  completedAt?: Date;
}