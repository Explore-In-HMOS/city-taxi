export enum VehicleType {
  standard = 'STANDARD',
  xl = 'XL',
  premium = 'PREMIUM'
}

export interface VehicleConfig {
  type: VehicleType;
  label: string;
  multiplier: number;
  etaFactor: number;
  icon: ResourceStr;
}

export const VEHICLES: Record<VehicleType, VehicleConfig> = {
  [VehicleType.standard]: {
    type: VehicleType.standard,
    label: 'Standard',
    multiplier: 1.0,
    etaFactor: 1.0,
    icon: $r('app.media.standard')
  },
  [VehicleType.xl]: {
    type: VehicleType.xl,
    label: 'XL',
    multiplier: 1.4,
    etaFactor: 1.1,
    icon: $r('app.media.xl')
  },
  [VehicleType.premium]: {
    type: VehicleType.premium,
    label: 'Premium',
    multiplier: 1.9,
    etaFactor: 1.15,
    icon: $r('app.media.premium')
  }
};

export type DiscountType = 'PERCENT' | 'FIXED';

/**
 * User decides which discount source to apply.
 * - AUTO: apply the better one among available (campaign vs coupon)
 * - CAMPAIGN: force campaign only
 * - COUPON: force coupon only
 * - NONE: no discount
 */
export type DiscountChoice = 'AUTO' | 'CAMPAIGN' | 'COUPON' | 'NONE';

export interface ActiveWindowSchedule {
  startMin: number;
  endMin: number;
}

export interface Campaign {
  id: string;
  title: string;
  endsAtMs: number;
  discountType: DiscountType;
  amount: number;
  eligibleVehicleTypes?: VehicleType[];
  stackableWithCoupon: boolean;
  activeWindows?: Array<ActiveWindowSchedule>;
}

export interface Coupon {
  code: string;
  title: string;
  expiresAtMs: number;
  discountType: DiscountType;
  amount: number;
  minSubtotal?: number;
  eligibleVehicleTypes?: VehicleType[];
  stackableWithCampaign: boolean;
}

export interface QuoteInput {
  pickupLat: number;
  pickupLng: number;
  dropOffLat: number;
  dropOffLng: number;
  vehicleType: VehicleType;
  couponCode?: string;
  discountChoice?: DiscountChoice; // default AUTO
}

export interface PriceBreakdown {
  currency: string;
  distanceKm: number;
  baseFare: number;
  distanceFare: number; // perKm x distance
  preMultiplierSubtotal: number; // sum of base and distanceFare
  vehicleMultiplier: number;
  vehicleSurcharge: number; // subtotal x (multi-1)
  subtotal: number; // (base+distance) x multi

  campaignDiscount: number;
  couponDiscount: number;
  totalDiscount: number;
  total: number;
}

export interface QuoteResult {
  breakdown: PriceBreakdown;
  appliedCampaignId?: string;
  appliedCouponCode?: string;
  warnings: string[];
  errors: string[];
}

export class PriceBreakdownImpl implements PriceBreakdown {
  currency: string = '';
  distanceKm: number = 0;
  baseFare: number = 0;
  distanceFare: number = 0;
  preMultiplierSubtotal: number = 0;
  vehicleMultiplier: number = 1;
  vehicleSurcharge: number = 0;
  subtotal: number = 0;
  campaignDiscount: number = 0;
  couponDiscount: number = 0;
  totalDiscount: number = 0;
  total: number = 0;
}

export class QuoteResultImpl implements QuoteResult {
  breakdown: PriceBreakdown = new PriceBreakdownImpl();
  appliedCampaignId?: string = undefined;
  appliedCouponCode?: string = undefined;
  warnings: string[] = [];
  errors: string[] = [];
}
