import { defineWorkersConfig } from '@cloudflare/vitest-pool-workers/config';

export default defineWorkersConfig({
  test: {
    globalSetup: ['./integration/global-setup.ts'],
    poolOptions: {
      workers: {
        singleWorker: true,
        wrangler: {
          configPath: '../wrangler/config.toml',
          environment: 'test'
        }
      }
    }
  }
});
