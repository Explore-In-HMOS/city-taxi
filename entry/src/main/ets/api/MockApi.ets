import { DriverInfo } from '../common/models/RideModel';
import { AddressInfo } from '../common/models/AddressModel';
import { Injectable } from '../registry/Injectable';

export abstract class MockApi extends Injectable {
  abstract onDispose(): void;

  abstract helloMockAPI(): Promise<string>;

  abstract fetchDriver(): Promise<DriverInfo>;

  abstract fetchDriverDistance(): Promise<number>;

  abstract submitDriverRating(rideId: string, rating: number): Promise<boolean>;

  abstract searchPlaces(keyword: string, center?: AddressInfo): Promise<AddressInfo[]>;
}
