import { SELF } from 'cloudflare:test';
import { expect, it } from 'vitest';

it('can fetch via SELF', async () => {
  const response = await SELF.fetch('https://fake.host/');

  expect(response.status).toBe(200);

  expect(await response.text()).toContain('👋 Hello from the Worker');
});

it('renders templates', async () => {
  const response = await SELF.fetch('https://fake.host/template');
  const text = await response.text();

  expect(response.headers.get('content-type')).toEqual(
    'text/html; charset=utf-8'
  );

  expect(text).toContain('Template Example');
  expect(text).toContain('vars.ENV: test');
});

it('returns a generic json response', async () => {
  const response = await SELF.fetch('https://fake.host/json');

  expect(response.headers.get('content-type')).toEqual('application/json');

  expect(await response.json()).toMatchObject({
    status: 200,
    message: 'Some JSON response message.'
  });
});

it('returns var values', async () => {
  const response = await SELF.fetch('https://fake.host/json');

  expect(await response.json()).toMatchObject({
    vars: {
      ENV: 'test'
    }
  });
});
