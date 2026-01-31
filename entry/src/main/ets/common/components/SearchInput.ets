@Component
export struct SearchInput {
  @State value: string = '';
  onSearch?: (value: string) => void | Promise<void>;

  build() {
    Row() {
      TextInput({ text: this.value, placeholder: 'Search place...' })
        .onChange((val: string) => this.value = val)
        .width('60%')
        .height(36)

      Image($r('app.media.search'))
        .width(24)
        .height(24)
        .onClick(async () => {
          await this.onSearch?.(this.value);
        })
    }
    .alignItems(VerticalAlign.Center)
  }
}
