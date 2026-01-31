import {
  QuoteInput,
  QuoteResult,
  QuoteResultImpl,
  PriceBreakdownImpl,
  VehicleType,
  VehicleConfig,
  VEHICLES,
  DiscountChoice,
  Campaign,
  Coupon
} from '../models/PricingModel';
import { CampaignService } from './CampaignService';
import { CouponService } from './CouponService';
import { RideHelper } from './RideHelper';

// ---------- CONSTANTS ----------
const CURRENCY: string = 'TRY';
const BASE_FARE: number = 200;
const PER_KM: number = 12;
const MIN_TOTAL: number = 20;

// ---------- HELPERS ----------
function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

function computeDiscount(type: 'PERCENT' | 'FIXED', amount: number, base: number): number {
  if (base <= 0) {
    return 0;
  }
  if (type === 'PERCENT') {
    return (base * amount) / 100;
  }
  return Math.min(base, amount);
}

function getVehicleConfig(type: VehicleType): VehicleConfig {
  const cfg: VehicleConfig = VEHICLES[type] as VehicleConfig;
  return cfg;
}

function normalizeChoice(choice?: DiscountChoice): DiscountChoice {
  return choice ?? 'AUTO';
}

export class PricingService {
  static calculate(input: QuoteInput, nowMs: number): QuoteResult {
    const out: QuoteResultImpl = new QuoteResultImpl();
    let vehicleCfg: VehicleConfig;

    // Vehicle type check
    try {
      vehicleCfg = getVehicleConfig(input.vehicleType);
    } catch (_) {
      out.errors.push('Vehicle type is required');
      vehicleCfg = getVehicleConfig(VehicleType.standard);
    }

    const discountChoice = normalizeChoice(input.discountChoice);

    // ---- Distance ----
    const distanceKm: number = RideHelper.calculateDistance(
      input.pickupLat,
      input.pickupLng,
      input.dropOffLat,
      input.dropOffLng
    );

    const hasDestination = distanceKm > 0;

    if (!hasDestination) {
      out.warnings.push('Select destination to see estimated price');
    }

    // ---- Base fares ----
    const baseFare: number = BASE_FARE;
    const distanceFare: number = distanceKm * PER_KM;
    const preMultiplierSubtotal: number = baseFare + distanceFare;

    const multiplier: number = vehicleCfg.multiplier;
    const subtotal: number = preMultiplierSubtotal * multiplier;
    const vehicleSurcharge: number = subtotal - preMultiplierSubtotal;

    // Campaign and coupon calculation
    const campaign: Campaign | null = CampaignService.getActiveCampaign(nowMs);
    let campaignDiscountPotential = 0;

    if (campaign && CampaignService.remainingSeconds(campaign, nowMs) > 0) {
      if (CampaignService.isEligible(campaign, input.vehicleType)) {
        campaignDiscountPotential = computeDiscount(campaign.discountType, campaign.amount, subtotal);
      } else {
        out.warnings.push('Campaign not eligible for selected vehicle');
      }
    }

    const couponCodeRaw: string = (input.couponCode ?? '').trim();
    let couponDiscountPotential = 0;
    let couponObj: Coupon | null = null;

    if (couponCodeRaw.length > 0) {
      const validation = CouponService.validate(couponCodeRaw, nowMs, input.vehicleType, subtotal);
      out.warnings.push(...validation.warnings);
      out.errors.push(...validation.errors);
      couponObj = validation.coupon; // Now couponObj is assigned here
      if (couponObj) {
        couponDiscountPotential = computeDiscount(couponObj.discountType, couponObj.amount, subtotal);
      }
    }

    // Apply both discounts if both are available
    let campaignDiscount = 0;
    let couponDiscount = 0;

    // Apply Campaign discount if available
    if (campaignDiscountPotential > 0) {
      campaignDiscount = campaignDiscountPotential;
    }
    // Apply Coupon discount if available
    if (couponDiscountPotential > 0) {
      couponDiscount = couponDiscountPotential;
    }
    // Total discount logic (sum of campaign and coupon discounts)
    const totalDiscount: number = Math.min(subtotal, campaignDiscount + couponDiscount);
    let total: number = subtotal - totalDiscount;
    if (total < MIN_TOTAL) {
      total = MIN_TOTAL;
    }

    // Apply breakdown calculations
    const b: PriceBreakdownImpl = new PriceBreakdownImpl();
    b.currency = CURRENCY;
    b.distanceKm = distanceKm;
    b.baseFare = round2(baseFare);
    b.distanceFare = round2(distanceFare);
    b.preMultiplierSubtotal = round2(preMultiplierSubtotal);
    b.vehicleMultiplier = multiplier;
    b.vehicleSurcharge = round2(vehicleSurcharge);
    b.subtotal = round2(subtotal);
    b.campaignDiscount = round2(campaignDiscount);
    b.couponDiscount = round2(couponDiscount);
    b.totalDiscount = round2(totalDiscount);
    b.total = round2(total);

    out.breakdown = b;
    return out;
  }
}
