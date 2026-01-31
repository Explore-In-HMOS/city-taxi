import { AddressInfo } from '../common/models/AddressModel';

import { MockApiImpl } from '../api/MockApiImpl';
import { SearchInput } from '../common/components/SearchInput';
import { PoiCard } from '../common/components/PoiCard';

@Builder
export function AddressSearchPageBuilder() {
  AddressSearchPage()
}

@Component
struct AddressSearchPage {
  private mockApi: MockApiImpl = new MockApiImpl();
  @State results: AddressInfo[] = [];
  @State statusText: string = '';
  pathStack: NavPathStack = new NavPathStack();
  centerAddress: AddressInfo = { latitude: 0, longitude: 0 };

  private _onSelectAddress(address: AddressInfo): void {
    this.pathStack.pop({ address });
  }

  async onSearch(keyword: string) {
    const kw = keyword?.trim();
    let results: AddressInfo[] = [];
    let statusText: string = '';
    if (!kw) {
      statusText = 'Type a search keyword.';
    } else if (!this.centerAddress) {
      statusText = 'Missing current location.';
    } else {
      try {
        results = await this.mockApi.searchPlaces(kw, this.centerAddress);
        statusText = results.length > 0 ? '' : 'No results found.';
      } catch (e) {
        console.error(`AddressSearchPage search failed: ${JSON.stringify(e)} Error: ${e}`);
        statusText = 'Search failed. Check logs.';
      }
    }
    this.results = results;
    this.statusText = statusText;
  }

  build() {
    NavDestination() {
      Column() {
        SearchInput({ onSearch: (kw): Promise<void> => this.onSearch(kw) })
          .padding({ top: 16 })

        if (this.statusText) {
          Text(this.statusText)
            .fontSize(12)
            .opacity(0.6)
            .padding({ top: 8, bottom: 8 })
        }

        Scroll() {
          Column() {
            ForEach(this.results, (p: AddressInfo) => {
              PoiCard({ address: p })
                .onClick(() => this._onSelectAddress(p))
            }, (p: AddressInfo) => p.address)
          }
        }
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const ids: number[] | undefined = this.pathStack.getIndexByName('AddressSearchPage');
      if (Array.isArray(ids) && ids.length > 0) {
        const idx = ids[ids.length - 1];
        this.centerAddress = this.pathStack.getParamByIndex(idx) as AddressInfo;
        this.statusText = '';
      } else {
        this.statusText = 'Missing current location.';
      }
    })
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }
}
