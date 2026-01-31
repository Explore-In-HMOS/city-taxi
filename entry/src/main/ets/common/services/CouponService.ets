import { Coupon, VehicleType } from '../models/PricingModel';

export interface CouponValidationResult {
  coupon: Coupon | null;
  warnings: string[];
  errors: string[];
}

export class CouponService {
  static getCouponByCode(codeRaw: string, nowMs: number): Coupon | null {
    const code = (codeRaw || '').trim().toUpperCase();
    if (!code) {
      return null;
    }

    const db: Coupon[] = [
      {
        code: 'WELCOME10',
        title: 'Welcome 10%',
        expiresAtMs: nowMs + 365 * 24 * 60 * 60 * 1000,
        discountType: 'PERCENT',
        amount: 10,
        minSubtotal: 80,
        stackableWithCampaign: true
      },
      {
        code: 'TAKE20',
        title: '20₺ OFF',
        expiresAtMs: nowMs + 365 * 24 * 60 * 60 * 1000,
        discountType: 'FIXED',
        amount: 20,
        minSubtotal: 100,
        stackableWithCampaign: true
      },
      {
        code: 'XL15',
        title: 'XL 15% OFF',
        expiresAtMs: nowMs + 365 * 24 * 60 * 60 * 1000,
        discountType: 'PERCENT',
        amount: 15,
        eligibleVehicleTypes: [VehicleType.xl],
        stackableWithCampaign: false
      }
    ];

    return db.find(c => c.code === code) ?? null;
  }

  static validate(codeRaw: string, nowMs: number, vehicleType: VehicleType, subtotal: number): CouponValidationResult {
    const warnings: string[] = [];
    const errors: string[] = [];

    const couponCodeProvided = (codeRaw || '').trim().length > 0;

    const coupon = CouponService.getCouponByCode(codeRaw, nowMs);
    if (!coupon) {
      errors.push('Invalid coupon code');
      return { coupon: null, warnings, errors };
    }

    if (coupon.expiresAtMs <= nowMs) {
      errors.push('C expired');
      return { coupon: null, warnings, errors };
    }

    if (coupon.eligibleVehicleTypes && coupon.eligibleVehicleTypes.length > 0 &&
      !coupon.eligibleVehicleTypes.includes(vehicleType)) {
      errors.push('Coupon not eligible for selected vehicle');
      return { coupon: null, warnings, errors };
    }

    if (couponCodeProvided && coupon.minSubtotal !== undefined && subtotal < coupon.minSubtotal) {
      warnings.push(`Coupon requires min subtotal ${coupon.minSubtotal}`);
      return { coupon: null, warnings, errors };
    }

    if (!coupon.stackableWithCampaign) {
      warnings.push('Coupon cannot be stacked with campaigns');
    }

    return { coupon, warnings, errors };
  }
}
