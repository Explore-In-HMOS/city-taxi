import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import geoLocationManager from '@ohos.geoLocationManager';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { AddressInfo } from '../../common/models/AddressModel';

export interface AddressSelectionFromMapDeps {
  getCurrentAddress: () => AddressInfo;
  setCurrentAddress: (address: AddressInfo) => void;
  getHostContext: () => common.UIAbilityContext;
}

export class AddressSelectionFromMap {
  readonly TAG: string = 'MapKit';
  readonly mapOptions: mapCommon.MapOptions;
  readonly mapCallback: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private lastObservedCenter?: AddressInfo;
  private cameraPositionPollIntervalId?: number;
  private cameraIdleDebounceTimeoutId?: number;
  private reverseGeocodeInFlight: boolean = false;
  private lastSelectedFromSearch?: AddressInfo;
  private didCenterOnCurrentLocation: boolean = false;
  private selectedAddressFromSearch?: AddressInfo;
  private deps: AddressSelectionFromMapDeps;

  constructor(deps: AddressSelectionFromMapDeps) {
    this.deps = deps;
    this.mapOptions = {
      position: { target: { latitude: 41.0082, longitude: 28.9784 }, zoom: 14 }
    };

    this.mapCallback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        const permission = await this.checkPermissions();
        if (!permission) {
          this.requestPermissions();
        } else {
          this.mapController?.setMyLocationControlsEnabled(true);
          void this._tryCenterMapOnCurrentLocation();
        }
        this._startCameraPositionWatch();
      } else {
        console.error(`Failed to initialize the map. Code: ${err.code}; message: ${err.message}`);
      }
    };
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController.show();
    }
    this._startCameraPositionWatch();
    void this._tryCenterMapOnCurrentLocation();

    if (this.lastSelectedFromSearch) {
      this.applySelectedAddress(this.lastSelectedFromSearch);
      this.lastSelectedFromSearch = undefined;
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
    this._stopCameraPositionWatch();
  }

  aboutToDisappear(): void {
    this._stopCameraPositionWatch();
  }

  applySelectedAddress(address: AddressInfo): void {
    if (!address || typeof address.latitude !== 'number' || typeof address.longitude !== 'number') {
      return;
    }
    this.selectedAddressFromSearch = address;
    this.deps.setCurrentAddress(address);
    this.lastObservedCenter = {
      latitude: address.latitude,
      longitude: address.longitude,
      address: address.address,
      name: address.name
    };

    const target: mapCommon.LatLng = { latitude: address.latitude, longitude: address.longitude };
    if (this.mapOptions?.position) {
      this.mapOptions.position.target = target;
    }
    if (!this.mapController) {
      this.lastSelectedFromSearch = address;
      return;
    }
    const zoomToUse = this.mapController?.getCameraPosition?.()?.zoom ?? (this.mapOptions?.position?.zoom ?? 10);
    void this._moveMapTo(this.mapController, address.latitude, address.longitude, zoomToUse)
      .catch((e: BusinessError) => console.error(this.TAG, `Failed to center map: ${JSON.stringify(e)}`));
  }

  getCenterLatLng(): mapCommon.LatLng | null {
    const cameraPosition: mapCommon.CameraPosition | undefined = this.mapController?.getCameraPosition?.();
    const target = cameraPosition?.target ?? this.mapOptions?.position?.target;
    const latitude: number | undefined = target?.latitude;
    const longitude: number | undefined = target?.longitude;
    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
      return null;
    }
    return { latitude, longitude };
  }

  private _startCameraPositionWatch(): void {
    if (!this.mapController) {
      return;
    }
    if (typeof this.cameraPositionPollIntervalId === 'number') {
      return;
    }

    void this._logCenterMarkerAddress();
    this.cameraPositionPollIntervalId = setInterval(() => {
      const cameraPosition: mapCommon.CameraPosition | undefined = this.mapController?.getCameraPosition();
      const target = cameraPosition?.target ?? this.mapOptions?.position?.target;
      const latitude: number | undefined = target?.latitude;
      const longitude: number | undefined = target?.longitude;
      if (typeof latitude !== 'number' || typeof longitude !== 'number') {
        return;
      }
      const changed = this._hasCenterChanged({ latitude, longitude });
      if (!changed) {
        return;
      }
      this.deps.setCurrentAddress({ address: '...', latitude: 0, longitude: 0 });
      if (typeof this.cameraIdleDebounceTimeoutId === 'number') {
        clearTimeout(this.cameraIdleDebounceTimeoutId);
      }
      this.cameraIdleDebounceTimeoutId = setTimeout(() => {
        void this._logCenterMarkerAddress();
      }, 700);
    }, 250);
  }

  private _stopCameraPositionWatch(): void {
    if (typeof this.cameraPositionPollIntervalId === 'number') {
      clearInterval(this.cameraPositionPollIntervalId);
      this.cameraPositionPollIntervalId = undefined;
    }
    if (typeof this.cameraIdleDebounceTimeoutId === 'number') {
      clearTimeout(this.cameraIdleDebounceTimeoutId);
      this.cameraIdleDebounceTimeoutId = undefined;
    }
  }

  private _hasCenterChanged(center: AddressInfo): boolean {
    const previous = this.lastObservedCenter;
    this.lastObservedCenter = center;
    if (!previous) {
      return true;
    }
    const threshold = 0.00001;
    return Math.abs(previous.latitude - center.latitude) > threshold ||
      Math.abs(previous.longitude - center.longitude) > threshold;
  }

  private async _moveMapTo(
    mapController: map.MapComponentController,
    latitude: number,
    longitude: number,
    zoom: number
  ): Promise<void> {
    const target: mapCommon.LatLng = { latitude, longitude };
    const cameraPosition: mapCommon.CameraPosition = { target, zoom };
    const cameraUpdate: map.CameraUpdate = map.newCameraPosition(cameraPosition);
    mapController.animateCamera(cameraUpdate, 1000);
  }

  private _isAtSelectedSearchAddress(latitude: number, longitude: number): boolean {
    const selected = this.selectedAddressFromSearch;
    if (!selected) {
      return false;
    }
    if (typeof selected.latitude !== 'number' || typeof selected.longitude !== 'number') {
      return false;
    }
    return Math.max(Math.abs(selected.latitude - latitude), Math.abs(selected.longitude - longitude)) <= 0.00001;
  }

  async checkPermissions(): Promise<boolean> {
    const permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    for (const permission of permissions) {
      const grantStatus: abilityAccessCtrl.GrantStatus = await this._checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        return true;
      }
    }
    return false;
  }

  requestPermissions(): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.deps.getHostContext(),
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => {
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        void this._tryCenterMapOnCurrentLocation();
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
  }

  private async _tryCenterMapOnCurrentLocation(): Promise<void> {
    if (this.didCenterOnCurrentLocation) {
      return;
    }
    if (!this.mapController) {
      return;
    }
    const permissionGranted = await this.checkPermissions();
    const current = await this._getCurrentLocationLatLng();
    if (!current || !permissionGranted) {
      return;
    }
    this.didCenterOnCurrentLocation = true;
    if (this.mapOptions?.position) {
      this.mapOptions.position.target = current;
    }
    this.deps.setCurrentAddress({ address: '...', latitude: current.latitude, longitude: current.longitude });
    this.lastObservedCenter = undefined;
    const zoomToUse = this.mapController?.getCameraPosition?.()?.zoom ?? (this.mapOptions?.position?.zoom ?? 16);
    await this._moveMapTo(this.mapController, current.latitude, current.longitude, zoomToUse);
  }

  private async _getCurrentLocationLatLng(): Promise<mapCommon.LatLng | null> {
    return await new Promise<mapCommon.LatLng | null>((resolve) => {
      try {
        geoLocationManager.getCurrentLocation((err: BusinessError, location: geoLocationManager.Location) => {
          if (err) {
            console.error(this.TAG, `getCurrentLocation failed: ${JSON.stringify(err)}`);
            resolve(null);
            return;
          }
          const latitude = location?.latitude;
          const longitude = location?.longitude;
          if (typeof latitude !== 'number' || typeof longitude !== 'number') {
            console.warn(this.TAG, `getCurrentLocation returned invalid coords: ${JSON.stringify(location)}`);
            resolve(null);
            return;
          }
          resolve({ latitude, longitude });
        });
      } catch (e) {
        console.error(this.TAG, `getCurrentLocation threw: ${JSON.stringify(e)}`);
        resolve(null);
      }
    });
  }

  private async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    const bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      console.error('checkAccessToken failed:', error);
      grantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    }
    console.info('Succeeded in checking access token.');
    return grantStatus;
  }

  private async _logCenterMarkerAddress(): Promise<void> {
    if (this.reverseGeocodeInFlight) {
      return;
    }
    this.reverseGeocodeInFlight = true;
    const cameraPosition: mapCommon.CameraPosition | undefined = this.mapController?.getCameraPosition();
    const target = cameraPosition?.target ?? this.mapOptions?.position?.target;
    const latitude: number | undefined = target?.latitude;
    const longitude: number | undefined = target?.longitude;
    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
      console.warn(this.TAG, 'Unable to determine map center coordinates yet.');
      this.reverseGeocodeInFlight = false;
      return;
    }
    if (this._isAtSelectedSearchAddress(latitude, longitude)) {
      const selected = this.selectedAddressFromSearch as AddressInfo;
      this.deps.setCurrentAddress({
        name: selected.name,
        address: selected.address,
        latitude,
        longitude
      });
      this.reverseGeocodeInFlight = false;
      return;
    }

    try {
      const isGeocoderAvailable = geoLocationManager?.isGeocoderAvailable;
      if (typeof isGeocoderAvailable === 'function' && !isGeocoderAvailable()) {
        console.info(this.TAG, `Marker coordinate: ${latitude}, ${longitude}`);
        console.warn(this.TAG, 'Geocoder service not available on this device.');
        this.deps.setCurrentAddress({ address: 'Geocoder unavailable', latitude, longitude });
        this.reverseGeocodeInFlight = false;
        return;
      }
    } catch (e) {
      console.info(this.TAG, `Marker coordinate: ${latitude}, ${longitude}`);
      console.error(this.TAG, `isGeocoderAvailable failed: ${e?.message ?? e}`);
      this.deps.setCurrentAddress({ address: 'Geocoder unavailable', latitude, longitude });
      this.reverseGeocodeInFlight = false;
      return;
    }

    const getAddressesFromLocation = geoLocationManager?.getAddressesFromLocation;
    if (typeof getAddressesFromLocation !== 'function') {
      console.info(this.TAG, `Marker coordinate: ${latitude}, ${longitude}`);
      console.warn(this.TAG, 'Reverse geocode API not available (geoLocationManager.getAddressesFromLocation).');
      this.deps.setCurrentAddress({ address: 'Reverse geocode unavailable', latitude, longitude });
      this.reverseGeocodeInFlight = false;
      return;
    }

    try {
      let results: geoLocationManager.GeoAddress[];
      try {
        const maybePromise = getAddressesFromLocation({ latitude, longitude, maxItems: 1 });
        if (maybePromise && typeof maybePromise.then === 'function') {
          results = await maybePromise;
        } else {
          results = await new Promise<geoLocationManager.GeoAddress[]>((resolve, reject) => {
            getAddressesFromLocation({ latitude, longitude, maxItems: 1 },
              (err, res: geoLocationManager.GeoAddress[]) => {
                if (err) {
                  reject(err);
                } else {
                  resolve(res);
                }
              });
          });
        }
      } catch (e) {
        results = await new Promise<geoLocationManager.GeoAddress[]>((resolve, reject) => {
          getAddressesFromLocation({ latitude, longitude, maxItems: 1 },
            (err, res: geoLocationManager.GeoAddress[]) => {
              if (err) {
                reject(err);
              } else {
                resolve(res);
              }
            });
        });
      }

      const address = Array.isArray(results) ? results[0] : results;
      this.deps.setCurrentAddress({
        address: this._formatAddress(address),
        name: this._formatAddress(address, true),
        latitude,
        longitude
      });
    } catch (e) {
      console.info(this.TAG, `Marker coordinate: ${latitude}, ${longitude}`);
      console.error(this.TAG, `Reverse geocode failed: ${e?.message ?? e}`);
      this.deps.setCurrentAddress({ address: 'Unknown Address', latitude, longitude });
    } finally {
      this.reverseGeocodeInFlight = false;
    }
  }

  private _formatAddress(address: geoLocationManager.GeoAddress, shortAddress: boolean = false): string {
    if (!address) {
      return 'Unknown address';
    }
    let candidates: Array<string | undefined> = [
      address.placeName,
      address.roadName,
      address.subRoadName,
      address.countryName
    ];
    if (shortAddress) {
      candidates = [address.placeName];
    }
    const parts: string[] = [];
    for (const part of candidates) {
      if (typeof part === 'string' && part.trim().length > 0) {
        parts.push(part);
      }
    }
    return parts.length > 0 ? parts.join(', ') : JSON.stringify(address);
  }
}