import { DriverInfo } from '../common/models/RideModel';
import { AddressInfo } from '../common/models/AddressModel';
import { MockApi } from './MockApi';

export class MockApiImpl extends MockApi {
  async helloMockAPI(): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve('hello mock api');
      }, 500);
    });
  }

  async fetchDriver(): Promise<DriverInfo> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          name: 'John Smith',
          rating: 4.9,
          vehiclePlate: '34 ABC 123',
          vehicleModel: 'Toyota Corolla',
          vehicleColor: 'Silver',
          phoneNumber: '+901231230000'
        });
      }, 5000);
    });
  }

  async fetchDriverDistance(): Promise<number> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 1km
        resolve(1);
      }, 500);
    });
  }

  async submitDriverRating(rideId: string, rating: number): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      setTimeout(() => {
        console.info(`Rating submitted for ride ${rideId}: ${rating} stars`);
      }, 500);
    });
  }

  async searchPlaces(keyword: string, center?: AddressInfo): Promise<AddressInfo[]> {
    const kw = keyword?.trim().toLowerCase() ?? '';
    const mockPlaces: AddressInfo[] = [
      {
        name: 'Ayasofya',
        address: 'Sultan Ahmet, Ayasofya Meydanı, Fatih',
        latitude: 41.008587,
        longitude: 28.980164
      },
      {
        name: 'Sultan Ahmet Camii',
        address: 'Sultan Ahmet Camii, Fatih',
        latitude: 41.005409,
        longitude: 28.976813
      },
      {
        name: 'Galata Kulesi',
        address: 'Bereketzade, Beyoğlu',
        latitude: 41.025608,
        longitude: 28.974153
      },
      {
        name: 'Taksim Meydani',
        address: 'Taksim Meydanı, Beyoğlu',
        latitude: 41.036949,
        longitude: 28.985091
      },
      {
        name: 'Kapali carsi',
        address: 'Kapalıçarşı, Fatih',
        latitude: 41.010556,
        longitude: 28.968056
      },
      {
        name: 'Kadıköy iskele',
        address: 'Kadıköy İskele, Kadıköy',
        latitude: 40.992937,
        longitude: 29.023647
      },
      {
        name: 'Ortaköy Meydan',
        address: 'Ortaköy Meydanı, Beşiktaş',
        latitude: 41.047308,
        longitude: 29.026799
      },
      {
        name: 'Dolmabahçe Sarayi',
        address: 'Dolmabahçe Sarayı, Beşiktaş',
        latitude: 41.039023,
        longitude: 29.000309
      },
      {
        name: 'Kiz Kulesi',
        address: 'Kız Kulesi, Üsküdar',
        latitude: 41.021122,
        longitude: 29.004111
      },
      {
        name: 'Istiklal caddesi',
        address: 'İstiklal Caddesi, Beyoğlu',
        latitude: 41.033892,
        longitude: 28.978479
      }
    ];

    const matches = mockPlaces.filter(place => {
      const haystack = `${place.name ?? ''} ${place.address ?? ''}`.toLowerCase();
      return haystack.includes(kw);
    });

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(matches.slice(0, 15));
      }, 200);
    });
  }

  onDispose(): void {
  }
}
