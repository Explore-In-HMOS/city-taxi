import { AppColors } from '../constants/UIConstants';
import { Campaign } from '../models/PricingModel';
import { RideStatus } from '../models/RideModel';

export class RideHelper {
  static getStatusText(status: RideStatus): string {
    switch (status) {
      case RideStatus.none:
        return 'No active ride';
      case RideStatus.searching:
        return 'Finding driver...';
      case RideStatus.driverArriving:
        return 'Driver arriving';
      case RideStatus.inProgress:
        return 'In progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown status';
    }
  }

  static getStatusColor(status: RideStatus): string {
    switch (status) {
      case RideStatus.none:
        return AppColors.TEXT_TERTIARY;
      case RideStatus.searching:
        return AppColors.WARNING;
      case RideStatus.driverArriving:
        return AppColors.INFO;
      case RideStatus.inProgress:
      case RideStatus.completed:
        return AppColors.SUCCESS;
      case RideStatus.cancelled:
        return AppColors.ERROR;
      default:
        return AppColors.TEXT_TERTIARY;
    }
  }

  static calculateEta(distanceKm: number): number {
    const avgSpeed = 40; // avg km/h - in city
    const etaMinutes = Math.ceil((distanceKm / avgSpeed) * 60);
    return Math.max(etaMinutes, 1);
  }

  static calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371; // Earth radius in km
    const dLat = RideHelper._toRadians(lat2 - lat1);
    const dLon = RideHelper._toRadians(lng2 - lng1);

    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(RideHelper._toRadians(lat1)) * Math.cos(RideHelper._toRadians(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return Number(distance.toFixed(1));
  }

  private static _toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  static callDurationText(callDurationSec: number): string {
    const m = Math.floor(callDurationSec / 60);
    const s = callDurationSec % 60;
    const mm = m < 10 ? `0${m}` : `${m}`;
    const ss = s < 10 ? `0${s}` : `${s}`;
    return `${mm}:${ss}`;
  }

  static padZero(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  static formattedCampaignCountdown(activeCampaign: Campaign | null): string {
    if (!activeCampaign) {
      return '';
    }

    const now = Date.now();
    const remainingTime = activeCampaign.endsAtMs - now;

    if (remainingTime <= 0) {
      return '00:00:00';
    }

    const hours = Math.floor(remainingTime / (1000 * 60 * 60));
    const minutes = Math.floor((remainingTime % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((remainingTime % (1000 * 60)) / 1000);

    return `${RideHelper.padZero(hours)}:${RideHelper.padZero(minutes)}:${RideHelper.padZero(seconds)}`;
  }
}