// Ride DataService with context impl
import { AddressInfo } from '../common/models/AddressModel';
import { RideInfo } from '../common/models/RideModel';

export interface AppDatabase {
  initialize(context: Context): Promise<void>;

  insertSavedDestination(address: AddressInfo): Promise<number>;

  getSavedDestinations(): Promise<AddressInfo[]>;

  insertOldTrip(ride: RideInfo): Promise<number>;

  getOldTrips(): Promise<RideInfo[]>;
}