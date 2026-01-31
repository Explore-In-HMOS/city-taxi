import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import vibrator from '@ohos.vibrator';

export enum CityTaxiNotificationType {
  driverArriving1Min = 'driver_arriving_1_min'
}

export class NotificationService {
  private static published: Set<string> = new Set<string>();
  private static isNotificationPermissionChecked: boolean = false;

  static resetRide(rideId: string): void {
    const prefix: string = rideId.concat('::');
    const keys: string[] = Array.from(NotificationService.published);
    for (const k of keys) {
      if (k.startsWith(prefix)) {
        NotificationService.published.delete(k);
      }
    }
  }

  static publishOnce(key: string, req: notificationManager.NotificationRequest): void {
    if (NotificationService.published.has(key)) {
      return;
    }
    NotificationService.published.add(key);

    notificationManager.publish(req, (err) => {
      if (err) {
        console.error('[CityTaxi][Notification] publish failed: '.concat(JSON.stringify(err)));
        NotificationService.published.delete(key);
      } else {
        console.info('[CityTaxi][Notification] publish ok');
        NotificationService._vibrateOnNotificationSent();
      }
    });
  }

  static async getPermission(context: common.UIAbilityContext): Promise<void> {
    if (NotificationService.isNotificationPermissionChecked) {
      return;
    }

    try {
      const isEnabled = await notificationManager.isNotificationEnabled();
      if (!isEnabled) {
        await notificationManager.requestEnableNotification(context);
        console.info('[ANS] requestEnableNotification success');
      }
      NotificationService.isNotificationPermissionChecked = true;
    } catch (err) {
      console.error('[ANS] Notification permission check failed: ', err);
    }
  }

  static notifyDriverArrivingOneMinute(rideId: string, driverName: string): void {
    const type: CityTaxiNotificationType = CityTaxiNotificationType.driverArriving1Min;
    const key: string = rideId.concat('::', type);

    const req: notificationManager.NotificationRequest = {
      id: NotificationService._stableNotificationId(rideId, 60),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'CityTaxi',
          text: (driverName && driverName.length > 0 ? driverName : 'Driver') + ' is coming in 1 minutes.',
          additionalText: 'Be Ready 👀'
        }
      }
    };

    NotificationService.publishOnce(key, req);
  }

  private static _stableNotificationId(rideId: string, salt: number): number {
    let h: number = 0;
    for (let i = 0; i < rideId.length; i++) {
      h = (h * 31 + rideId.charCodeAt(i)) | 0;
    }
    const v: number = Math.abs(h) + salt;
    return v % 2147483000;
  }

  private static _vibrateOnNotificationSent(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 500
      }, {
        id: 0,
        usage: 'notification'
      }, (error: BusinessError) => {
        if (error) {
          console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info('Succeed in starting vibration');
      });
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}
