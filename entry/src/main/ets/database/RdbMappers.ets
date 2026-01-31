import { relationalStore } from '@kit.ArkData';
import { AddressInfo } from '../common/models/AddressModel';
import { RideInfo, RideStatus } from '../common/models/RideModel';
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
  COL_TRIP_PICKUP_ADDRESS,
  COL_TRIP_PICKUP_LAT,
  COL_TRIP_PICKUP_LNG,
  COL_TRIP_RIDE_ID,
  COL_TRIP_STATUS,
  COL_TRIP_VEHICLE_COLOR,
  COL_TRIP_VEHICLE_MODEL,
  COL_TRIP_VEHICLE_PLATE
} from './tables/OldTripsTable';
import { COL_ADDRESS, COL_ID, COL_LATITUDE, COL_LONGITUDE, COL_NAME } from './tables/SavedDestinationTable';

export function savedDestinationToRdb(savedAddress: AddressInfo): relationalStore.ValuesBucket {
  return {
    id: savedAddress.id ?? null,
    name: savedAddress.name ?? null,
    address: savedAddress.address ?? null,
    latitude: savedAddress.latitude,
    longitude: savedAddress.longitude,
    createdAt: savedAddress.createdAt ? Math.floor(savedAddress.createdAt.getTime() / 1000) : null
  };
}

/**
 * @param resultSet
 * @param createdDate
 * @throws { BusinessError }
 * */
export function rdbToSavedDestination(resultSet: relationalStore.ResultSet,
  createdDate: number): AddressInfo | undefined {
  return {
    id: resultSet.getLong(resultSet.getColumnIndex(COL_ID)),
    name: resultSet.getString(resultSet.getColumnIndex(COL_NAME)),
    address: resultSet.getString(resultSet.getColumnIndex(COL_ADDRESS)),
    latitude: resultSet.getDouble(resultSet.getColumnIndex(COL_LATITUDE)),
    longitude: resultSet.getDouble(resultSet.getColumnIndex(COL_LONGITUDE)),
    createdAt: createdDate === 0 ? new Date() : new Date(createdDate)
  };
}

export function oldTripToRdb(ride: RideInfo): relationalStore.ValuesBucket {
  return {
    RIDE_ID: ride.id,
    STATUS: ride.status,
    DRIVER_NAME: ride.driver?.name ?? null,
    DRIVER_RATING: ride.driver?.rating ?? null,
    VEHICLE_PLATE: ride.driver?.vehiclePlate ?? null,
    VEHICLE_MODEL: ride.driver?.vehicleModel ?? null,
    VEHICLE_COLOR: ride.driver?.vehicleColor ?? null,
    DRIVER_PHOTO_URL: ride.driver?.photoUrl ?? null,
    DRIVER_PHONE: ride.driver?.phoneNumber ?? null,
    PICKUP_ADDRESS: ride.pickupAddress.address ?? '',
    PICKUP_LAT: ride.pickupAddress.latitude,
    PICKUP_LNG: ride.pickupAddress.longitude,
    DROP_OFF_ADDRESS: ride.dropOffAddress?.address ?? '',
    DROP_OFF_LAT: ride.dropOffAddress?.latitude ?? null,
    DROP_OFF_LNG: ride.dropOffAddress?.longitude ?? null,
    DRIVER_DISTANCE_KM: ride.driverDistanceKm,
    TRIP_DISTANCE_KM: ride.tripDistanceKm ?? null,
    COST: ride.cost ?? null,
    CURRENCY: ride.currency ?? null,
    COMPLETED_AT: ride.completedAt ? ride.completedAt.getTime() : Date.now()
  };
}

/**
 * @param resultSet
 * @throws { BusinessError }
 * */
export function rdbToOldTrip(resultSet: relationalStore.ResultSet): RideInfo {
  const hasDriver = !resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_DRIVER_NAME));
  const hasDestination = !resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_DROP_OFF_LAT));

  const completedAtTimestamp = resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_COMPLETED_AT)) ?
      null :
      resultSet.getLong(resultSet.getColumnIndex(COL_TRIP_COMPLETED_AT));

  return {
    id: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_RIDE_ID)),
    status: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_STATUS)) as RideStatus,
    driver: hasDriver ? {
      name: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_DRIVER_NAME)),
      rating: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_DRIVER_RATING)),
      vehiclePlate: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_VEHICLE_PLATE)),
      vehicleModel: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_VEHICLE_MODEL)),
      vehicleColor: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_VEHICLE_COLOR)),
      photoUrl: resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_DRIVER_PHOTO_URL)) ?
          undefined :
          resultSet.getString(resultSet.getColumnIndex(COL_TRIP_DRIVER_PHOTO_URL)),
      phoneNumber: resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_DRIVER_PHONE)) ?
          undefined :
          resultSet.getString(resultSet.getColumnIndex(COL_TRIP_DRIVER_PHONE))
    } : null,
    pickupAddress: {
      address: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_PICKUP_ADDRESS)),
      latitude: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_PICKUP_LAT)),
      longitude: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_PICKUP_LNG))
    },
    dropOffAddress: hasDestination ? {
      address: resultSet.getString(resultSet.getColumnIndex(COL_TRIP_DROP_OFF_ADDRESS)),
      latitude: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_DROP_OFF_LAT)),
      longitude: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_DROP_OFF_LNG))
    } : null,
    driverDistanceKm: resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_DRIVER_DISTANCE_KM)),
    tripDistanceKm: resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_DISTANCE_KM)) ?
        undefined :
        resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_DISTANCE_KM)),
    cost: resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_COST)) ?
        undefined :
        resultSet.getDouble(resultSet.getColumnIndex(COL_TRIP_COST)),
    currency: resultSet.isColumnNull(resultSet.getColumnIndex(COL_TRIP_CURRENCY)) ?
        undefined :
        resultSet.getString(resultSet.getColumnIndex(COL_TRIP_CURRENCY)),
    completedAt: completedAtTimestamp ? new Date(completedAtTimestamp) : undefined
  };
}
