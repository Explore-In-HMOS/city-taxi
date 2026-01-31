import { BusinessError } from '@kit.BasicServicesKit';
import { call, observer } from '@kit.TelephonyKit';
import { Ride } from '../models/Ride';

export class CallService {
  private static registerCallObserver(ride: Ride): void {
    if (ride.callObserverRegistered) {
      return;
    }
    ride.callObserverRegistered = true;

    class CallStateCallback {
      state: call.CallState = call.CallState.CALL_STATE_UNKNOWN;
      number: string = '';
    }

    try {
      observer.on('callStateChange', { slotId: 0 }, (data: CallStateCallback) => {
        console.info('[CityTaxi] call state:', JSON.stringify(data));
      });
    } catch (error) {
      console.warn('[CityTaxi] observer not supported:', JSON.stringify(error));
    }
  }

  private static startMockConnectAfterDelay(ride: Ride, ms: number): void {
    if (ride.ringingTimeoutId !== null) {
      clearTimeout(ride.ringingTimeoutId);
    }
    ride.ringingTimeoutId = setTimeout(() => {
      CallService.onCallConnected(ride);
    }, ms) as number;
  }

  private static onCallConnected(ride: Ride): void {
    ride.callPhase = 'CONNECTED';
    ride.callTitle = `${ride.driver?.name ?? 'Driver'} connected`;

    if (ride.durationIntervalId !== null) {
      clearInterval(ride.durationIntervalId);
    }
    ride.durationIntervalId = setInterval(() => {
      ride.callDurationSec += 1;
    }, 1000) as number;
  }

  static callDriver(ride: Ride, setErrorMessage: (msg: string) => void): void {
    if (!ride.driver?.phoneNumber) {
      return;
    }

    const raw = (ride.driver.phoneNumber || '').trim();
    if (!raw) {
      setErrorMessage('Driver phone number is missing');
      return;
    }

    ride.isCallUIVisible = true;
    ride.callPhase = 'RINGING';
    ride.callDurationSec = 0;
    ride.callTitle = `Calling ${ride.driver.name || 'driver'}...`;
    setErrorMessage('');

    CallService.registerCallObserver(ride);
    const supported = call.hasVoiceCapability();
    console.info(`[CityTaxi] voice capability: ${supported}`);

    if (!supported) {
      CallService.startMockConnectAfterDelay(ride, 10_000);
      return;
    }

    const numberForDialer = raw.startsWith('tel:') ? raw.slice(4) : raw;

    call.makeCall(numberForDialer, (err: BusinessError) => {
      if (err) {
        setErrorMessage(`makeCall failed: ${JSON.stringify(err)}`);
        CallService.startMockConnectAfterDelay(ride, 3_000);
        return;
      }

      CallService.startMockConnectAfterDelay(ride, 10_000);
    });
  }

  static endCall(ride: Ride): void {
    if (ride.ringingTimeoutId !== null) {
      clearTimeout(ride.ringingTimeoutId);
      ride.ringingTimeoutId = null;
    }
    if (ride.durationIntervalId !== null) {
      clearInterval(ride.durationIntervalId);
      ride.durationIntervalId = null;
    }

    ride.callPhase = 'ENDED';
    ride.callTitle = 'Call ended';

    setTimeout(() => {
      ride.isCallUIVisible = false;
      ride.callPhase = 'IDLE';
      ride.callDurationSec = 0;
      ride.callTitle = '';
    }, 3000);
  }
}