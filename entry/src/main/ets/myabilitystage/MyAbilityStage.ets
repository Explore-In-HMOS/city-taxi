import { AbilityStage } from '@kit.AbilityKit';
import { MainRegistry } from '../di/MainRegistry';
import { ServiceRegistry } from '../registry/ServiceRegistry';
import connection from '@ohos.net.connection';
import { netHandover } from '@kit.NetworkBoostKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class MyAbilityStage extends AbilityStage {
  private registry: ServiceRegistry | null = null;
  private handoverListener?: (info: netHandover.HandoverInfo) => void;

  onCreate(): void {
    this.registry = MainRegistry.build(this.context.getApplicationContext());
    this.startDefaultNetworkListener();
    this.startHandoverListener();

  }

  onDestroy(): void {
    this.stopHandoverListener();
    this.registry?.destroy();
  }

  private startDefaultNetworkListener(): void {
    const defaultNet = connection.getDefaultNetSync();
    const netCapabilities = connection.getNetCapabilitiesSync(defaultNet);
    let bearerTypes = netCapabilities.bearerTypes;
    const netConnection = connection.createNetConnection();

    netConnection.on(
      'netCapabilitiesChange',
      (netCap: connection.NetCapabilityInfo) => {
        const newBearTypes = netCap.netCap.bearerTypes;
        if (newBearTypes !== bearerTypes) {
          bearerTypes = newBearTypes;
        }
      },
    );
  }

  private startHandoverListener(): void {
    if (this.handoverListener) {
      return;
    }

    const networkInfoAvailable = canIUse('SystemCapability.Communication.NetworkBoost.Core');

    if (networkInfoAvailable) {
      this.handoverListener = (info: netHandover.HandoverInfo) => {
        if (info.handoverStart) {
          console.info('handover start');
        } else if (info.handoverComplete) {
          console.info('handover complete');
        }
      };

      try {
        netHandover.on('handoverChange', this.handoverListener);
      } catch (err) {
        console.error(
          'errCode: ' +
          (err as BusinessError).code +
            ', errMessage: ' +
          (err as BusinessError).message,
        );
        this.handoverListener = undefined;
      }
    }
  }

  private stopHandoverListener(): void {

    const networkInfoAvailable = canIUse('SystemCapability.Communication.NetworkBoost.Core');

    if (!this.handoverListener) {
      return;
    }

    if (networkInfoAvailable) {
      try {
        netHandover.off('handoverChange');
      } catch (err) {
        console.error(
          'errCode: ' +
          (err as BusinessError).code +
            ', errMessage: ' +
          (err as BusinessError).message,
        );
      } finally {
        this.handoverListener = undefined;
      }
    }
  }
}
