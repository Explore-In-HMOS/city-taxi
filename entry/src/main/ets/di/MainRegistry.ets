import { MockApi } from '../api/MockApi';
import { MockApiImpl } from '../api/MockApiImpl';
import { Register, ServiceRegistry } from '../registry/ServiceRegistry';
import { UiRegistry } from '../registry/UIRegistry';

export class MainRegistry extends ServiceRegistry implements UiRegistry {
  context: Context;

  private constructor(context: Context) {
    super();
    this.context = context;
  }

  public static build(context: Context): MainRegistry {
    const instance = new MainRegistry(context);
    instance.initialize();
    return instance;
  }

  @Register(MockApi)
  registerMockApi(): MockApi {
    return new MockApiImpl();
  }
}
