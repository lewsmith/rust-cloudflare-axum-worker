# Rust Cloudflare Axum Worker

A Rust worker example for Cloudflare Workers using Axum.

---

This repo is a **very basic** example of running an Axum-based Rust worker on Cloudflare along with Vite integration
tests and working live reloading during development. I put this together to help others get started quickly.

Github and Gitlab CI configs are also included. These run linters, tests and allow **manual** deployments to
Cloudflare as a release or preview.

I will update with more features when I get time. This will include real unit tests & implementations of Cloudflare
features like D1, KV etc.

### Features

- Rust WASM worker
- Working live reload `make dev-watch`
- Wrangler config/vars in `/wrangler`
- Makefile support. Requires `make`, run to view available commands.
- [Biome](https://github.com/biomejs/biome) linting/formatting for TS integration tests.
- Working [Vitest](https://github.com/vitest-dev/vitest) integration testing
- Github & Gitlab CI configs
- Local Github actions testing via [Act](https://github.com/nektos/act)
- [Lint-staged](https://github.com/lint-staged/lint-staged) checks (linting/formatting)
  via [Husky](https://github.com/typicode/husky)

## Get Started

- Ensure Rust, Make & Node >= 18 is installed.
- Clone.
- Create `wrangler/.dev.vars` (`cp wrangler/.dev.vars.sample wrangler/.dev.vars`) and add your Cloudflare API Token
  & account ID.
- Run `make deps` to install node dependencies.
- Run `make help` to view available commands.

> Running `make dev` should start a local version of the worker on port 8787
>
> http://localhost:8787 - Shows an example message produced via Axum HTML.
> http://localhost:8787/api - Shows an example JSON response.

## CI/CD

For both Github and Gitlab you will need to add the environment
variables `CLOUDFLARE_API_TOKEN` & `CLOUDFLARE_ACCOUNT_ID` with
their respective values.

> For Gitlab you will also need to set the path to the `.gitlab-ci.yaml` file. This is because I like to keep my file
> structure as clean as possible and avoid config hell.
>
> You can set the path to the path to this file under your repo's 'Settings' -> 'CI/CD' -> 'General Pipelines' ->
> 'CI/CD configuration file'. Set this to `.gitlab/ci-pipeline.yml`

In order to actually deploy to Cloudflare via Github or Gitlab, you will need to manually run either of the two
deployment example actions/jobs.

## Contribute

PRs welcome!
