import { TaxiHome } from './taxihome/TaxiHome';
import { NotificationService } from '../common/services/NotificationService';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    NotificationService.getPermission(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  build() {
    Column() {
      TaxiHome()
    }
  }
}