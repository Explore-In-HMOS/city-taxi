import { AddressInfo } from '../models/AddressModel';

interface IParams {
  siteId: string;
  name: string;
}

@Component
export struct PoiCard {
  @Prop address: AddressInfo;

  build() {
    Column() {
      Text(this.address.name ?? 'Unknown')
        .fontSize(16)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
      Text(this.address.address ?? '')
        .fontSize(12)
        .opacity(0.6)
        .fontColor(Color.Black)
    }
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(12)
    .margin({ bottom: 8 })
  }
}
