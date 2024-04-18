declare module 'cloudflare:test' {
  // Controls the type of `import("cloudflare:test").env`
  interface ProvidedEnv {
    WORKER: Fetcher;
  }
}

interface ImportMetaEnv {
  readonly CI: boolean;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
