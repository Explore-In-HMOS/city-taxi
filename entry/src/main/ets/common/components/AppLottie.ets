import lottie, { AnimationItem } from '@ohos/lottie';

@Component
export struct AppLottie {
  @Prop @Require animationPath: string;
  @Prop lottieWidth: number | string | Resource = 120;
  @Prop lottieHeight: number | string | Resource = 120;
  @Prop loop: boolean = true;
  @Prop staticFrame: number = 0;
  private animationItem: AnimationItem | null = null;
  private animationName: string = `lottie_${Date.now()}`;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);

  aboutToDisappear(): void {
    if (this.animationName) {
      lottie.destroy(this.animationName);
    }
    this.animationItem = null;
  }

  build() {
    Canvas(this.canvasContext)
      .width(this.lottieWidth)
      .height(this.lottieHeight)
      .backgroundColor(Color.Transparent)
      .onReady(() => {
        this.canvasContext.imageSmoothingEnabled = true;
        this.canvasContext.imageSmoothingQuality = 'medium';

        this.animationItem = lottie.loadAnimation({
          container: this.canvasContext,
          renderer: 'canvas',
          loop: this.loop,
          autoplay: this.loop,
          name: this.animationName,
          contentMode: 'Contain',
          path: this.animationPath
        });

        if (!this.loop) {
          this.animationItem?.addEventListener('DOMLoaded', () => {
            this.animationItem?.goToAndStop(this.staticFrame, true);
          });
        }
      })
  }
}