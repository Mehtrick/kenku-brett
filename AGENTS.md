# AGENTS.md

## Project

Static mobile-friendly web UI for the [Kenku](https://www.kenku.fm/) soundboard. Served by nginx, which also reverse-proxies `/v1/` requests to a Kenku Remote API server.

## Architecture

- **Single-page app**: `index.html` — vanilla HTML/JS, Tailwind via CDN. No build step, no bundler, no package manager.
- **nginx proxy**: `default.conf.template` uses nginx's envsubst template feature. The `KENKU_IP` env var is substituted at container start to set the upstream for `/v1/` → `http://${KENKU_IP}:3333/v1/`.
- **Dockerfile** (lowercase `d`) — `nginx:alpine` base, copies the template and HTML, exposes port 80.

## Commands

```bash
# Build locally
docker build -f dockerfile -t kenku-brett .

# Run locally
docker run -d -p 8080:80 -e KENKU_IP=<kenku-host-lan-ip> kenku-brett
```

There are no tests, lint, or typecheck commands.

## CI

`.github/workflows/docker-publish.yml` — builds and pushes to `ghcr.io/<owner>/kenku-brett` on push to `main`/`master` or semver tags. PRs build but do not push.

## Conventions

- UI text is in German.
- The Dockerfile filename is intentionally lowercase — do not rename to `Dockerfile` without also updating the CI workflow and README.
