import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { AddressInfo } from '../common/models/AddressModel';
import { AppDatabase } from './AppDatabase';
import { oldTripToRdb, rdbToOldTrip, rdbToSavedDestination, savedDestinationToRdb } from './RdbMappers';
import { COL_ADDRESS,
  COL_CREATED_AT,
  COL_ID,
  COL_LATITUDE,
  COL_LONGITUDE,
  COL_NAME,
  SQL_CREATE_SAVED_DESTINATIONS,
  TABLE_SAVED_DESTINATIONS
} from './tables/SavedDestinationTable';
import { JSON } from '@kit.ArkTS';
import { RideInfo } from '../common/models/RideModel';
import { COL_TRIP_COMPLETED_AT,
  COL_TRIP_COST,
  COL_TRIP_CURRENCY,
  COL_TRIP_DISTANCE_KM,
  COL_TRIP_DRIVER_DISTANCE_KM,
  COL_TRIP_DRIVER_NAME,
  COL_TRIP_DRIVER_PHONE,
  COL_TRIP_DRIVER_PHOTO_URL,
  COL_TRIP_DRIVER_RATING,
  COL_TRIP_DROP_OFF_ADDRESS,
  COL_TRIP_DROP_OFF_LAT,
  COL_TRIP_DROP_OFF_LNG,
  COL_TRIP_ID,
  COL_TRIP_PICKUP_ADDRESS,
  COL_TRIP_PICKUP_LAT,
  COL_TRIP_PICKUP_LNG,
  COL_TRIP_RIDE_ID,
  COL_TRIP_STATUS,
  COL_TRIP_VEHICLE_COLOR,
  COL_TRIP_VEHICLE_MODEL,
  COL_TRIP_VEHICLE_PLATE,
  SQL_CREATE_OLD_TRIPS,
  TABLE_OLD_TRIPS
} from './tables/OldTripsTable';

const DB_NAME = 'city_taxi.db';

export class AppDatabaseImpl implements AppDatabase {
  private store: relationalStore.RdbStore | null = null;
  private initialized: boolean = false;

  async initialize(context: Context): Promise<void> {
    if (this.initialized && this.store !== null) {
      return;
    }

    const storeConfig: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1,
      encrypt: false
    };

    try {
      this.store = await relationalStore.getRdbStore(context, storeConfig);

      // Fresh db
      if (this.store.version === 0) {
        await this.store.execute(SQL_CREATE_SAVED_DESTINATIONS);
        await this.store.execute(SQL_CREATE_OLD_TRIPS);
        this.store.version = 2;
      } else if (this.store.version === 1) {
        // Migration here: Add old trips
        await this.store.execute(SQL_CREATE_OLD_TRIPS);
        this.store.version = 2;
      }

      this.initialized = true;
      console.info('AppDatabase initialized successfully(AppDatabase)');
    } catch (e) {
      console.error('Failed to initialize database:', JSON.stringify(e));
      return;
    }
  }

  async insertSavedDestination(address: AddressInfo): Promise<number> {
    if (!this.store) {
      return -1;
    }

    try {
      const values = savedDestinationToRdb(address);
      const rowId = await this.store.insert(TABLE_SAVED_DESTINATIONS, values);
      return rowId;
    } catch (e) {
      console.error('Failed to save address:', JSON.stringify(e));
      return -1;
    }
  }

  async getSavedDestinations(): Promise<AddressInfo[]> {
    if (!this.store) {
      return [];
    }

    const destinations: AddressInfo[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_SAVED_DESTINATIONS);
      const columns = [COL_ID, COL_NAME, COL_ADDRESS, COL_LATITUDE, COL_LONGITUDE, COL_CREATED_AT];
      const resultSet = await this.store.query(predicates, columns);

      while (resultSet.goToNextRow()) {
        const createdAt = resultSet.isColumnNull(resultSet.getColumnIndex(COL_CREATED_AT)) ?
          0 :
          resultSet.getLong(resultSet.getColumnIndex(COL_CREATED_AT));
        const address = rdbToSavedDestination(resultSet, createdAt);
        if (address) {
          destinations.push(address);
        }
      }
      resultSet.close();

      return destinations;
    } catch (e) {
      console.error('Failed to get saved addresses', JSON.stringify(e));
      return [];
    }
  }

  async insertOldTrip(ride: RideInfo): Promise<number> {
    if (!this.store) {
      return -1;
    }

    try {
      const values = oldTripToRdb(ride);
      const rowId = await this.store.insert(TABLE_OLD_TRIPS, values);
      return rowId;
    } catch (e) {
      console.error('Failed to save old trip:', JSON.stringify(e));
      return -1;
    }
  }

  async getOldTrips(): Promise<RideInfo[]> {
    if (!this.store) {
      return [];
    }

    const trips: RideInfo[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_OLD_TRIPS);
      predicates.orderByDesc(COL_TRIP_COMPLETED_AT);

      const columns = [
        COL_TRIP_ID,
        COL_TRIP_RIDE_ID,
        COL_TRIP_STATUS,
        COL_TRIP_DRIVER_NAME,
        COL_TRIP_DRIVER_RATING,
        COL_TRIP_VEHICLE_PLATE,
        COL_TRIP_VEHICLE_MODEL,
        COL_TRIP_VEHICLE_COLOR,
        COL_TRIP_DRIVER_PHOTO_URL,
        COL_TRIP_DRIVER_PHONE,
        COL_TRIP_PICKUP_ADDRESS,
        COL_TRIP_PICKUP_LAT,
        COL_TRIP_PICKUP_LNG,
        COL_TRIP_DROP_OFF_ADDRESS,
        COL_TRIP_DROP_OFF_LAT,
        COL_TRIP_DROP_OFF_LNG,
        COL_TRIP_DRIVER_DISTANCE_KM,
        COL_TRIP_DISTANCE_KM,
        COL_TRIP_COST,
        COL_TRIP_CURRENCY,
        COL_TRIP_COMPLETED_AT
      ];

      const resultSet = await this.store.query(predicates, columns);

      while (resultSet.goToNextRow()) {
        const trip = rdbToOldTrip(resultSet);
        trips.push(trip);
      }
      resultSet.close();

      return trips;
    } catch (e) {
      console.error('Failed to get saved addresses', JSON.stringify(e));
      return [];
    }
  }
}

// IMPORTANT: Singleton instance for easy access app-wide. Initialized only in EntryAbility
export const appDatabase: AppDatabase = new AppDatabaseImpl();