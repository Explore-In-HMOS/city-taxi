import { Campaign, VehicleType, ActiveWindowSchedule } from '../models/PricingModel';

function minutesOfDay(d: Date): number {
  return d.getHours() * 60 + d.getMinutes();
}

export function isWithinWindows(nowMin: number, windows: Array<ActiveWindowSchedule>): boolean {
  for (const w of windows) {
    if (nowMin >= w.startMin && nowMin < w.endMin) {
      return true;
    }
  }
  return false;
}

export function computeWindowEndAtMs(now: Date, windows: Array<ActiveWindowSchedule>): number {
  const nowMin = minutesOfDay(now);
  for (const w of windows) {
    if (nowMin >= w.startMin && nowMin < w.endMin) {
      const end = new Date(now.getTime());
      end.setHours(0, 0, 0, 0);
      end.setMinutes(w.endMin);
      return end.getTime();
    }
  }
  return now.getTime() + 15 * 60 * 1000;
}

export class CampaignService {
  static getActiveCampaign(nowMs: number): Campaign | null {
    const windows = [{ startMin: 8 * 60, endMin: 30 * 60 }] as ActiveWindowSchedule[];

    const now = new Date(nowMs);
    const nowMin = minutesOfDay(now);

    if (!isWithinWindows(nowMin, windows)) {
      return null;
    }

    const endsAt = computeWindowEndAtMs(now, windows);

    return {
      id: 'RUSH15',
      title: 'Off-Peak - 15% OFF',
      endsAtMs: endsAt,
      discountType: 'PERCENT',
      amount: 15,
      eligibleVehicleTypes: [VehicleType.standard, VehicleType.xl, VehicleType.premium],
      stackableWithCoupon: true,
      activeWindows: windows
    };
  }

  static remainingSeconds(campaign: Campaign, nowMs: number): number {
    const diff = campaign.endsAtMs - nowMs;
    return Math.max(0, Math.floor(diff / 1000));
  }

  static isEligible(campaign: Campaign, vehicleType: VehicleType): boolean {
    if (!campaign.eligibleVehicleTypes || campaign.eligibleVehicleTypes.length === 0) {
      return true;
    }
    return campaign.eligibleVehicleTypes.includes(vehicleType);
  }
}
