import { SELF } from 'cloudflare:test';
import { expect, it } from 'vitest';

it('dispatches fetch event', async () => {
  const hello = await SELF.fetch('https://fake.host/');
  expect(hello.status).toBe(200);
  expect(await hello.text()).toContain('👋 Hello from the Worker');

  const api = await SELF.fetch('https://fake.host/api');
  expect(api.status).toBe(200);
  expect(await api.text()).toEqual(
    JSON.stringify({
      status: 200,
      message: 'Some API response'
    })
  );
});
