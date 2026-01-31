@Component
export struct BubbleText {
  @Require @Prop text: string;

  build() {
    Stack({ alignContent: Alignment.Top }) {

      Column() {
        Text(this.text)
          .fontSize(10)
          .fontColor(Color.White)
          .padding(4)
          .backgroundColor(Color.Black)
          .border({
            width: 1,
            color: Color.Black
          })
          .borderRadius(6)
      }
      .width('100%')
      .position({ y: 23 })
      .justifyContent(FlexAlign.Center)

      Column() {
        Stack()
          .width(20)
          .height(20)
          .backgroundColor(Color.White)
          .border({
            width: 2,
            color: Color.Black
          })
          .borderRadius(5)
          .rotate({ angle: 45 })
          .margin({ top: 15 })
      }
      .rotate({
        y: 1,
        angle: 70
      })

      Column() {
        Text(this.text)
          .fontSize(10)
          .fontColor(Color.Black)
          .padding(4)
          .backgroundColor(Color.White)
          .borderRadius(5)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .position({ y: 23 })
      .padding(1)

    }

  }
}