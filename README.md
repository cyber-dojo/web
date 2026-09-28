This repo holds the apps below, each one of the services behind
[https://cyber-dojo.org](http://cyber-dojo.org), and each built into its own
docker image. The other services (eg saver, runner, differ) live in their own
repos.

| App | CI | What it serves |
|-----|----|----------------|
| [web](web/README.md) | [![main-web](https://github.com/cyber-dojo/web/actions/workflows/main-web.yml/badge.svg?branch=main)](https://github.com/cyber-dojo/web/actions/workflows/main-web.yml) | the core edit+review pages |
| [creator](creator/README.md) | [![main-creator](https://github.com/cyber-dojo/web/actions/workflows/main-creator.yml/badge.svg?branch=main)](https://github.com/cyber-dojo/web/actions/workflows/main-creator.yml) | the pages that create (or re-enter) a group or individual exercise |
| [dashboard](dashboard/README.md) | [![main-dashboard](https://github.com/cyber-dojo/web/actions/workflows/main-dashboard.yml/badge.svg?branch=main)](https://github.com/cyber-dojo/web/actions/workflows/main-dashboard.yml) | the group-exercise dashboard |

Each app has the same shape:

- its own directory, `<app>/`, holding its `source/`, `test/`, `bin/` and `docs/`
- its own Dockerfile stage, `<app>`, and its own image
- its own `<app>.env`, loaded only by its own compose service
- its own make targets, all named `<app>_<verb>` (eg `make dashboard_test_server`)
- its own workflow, `.github/workflows/main-<app>.yml`, run only when its
  files, or the files every app shares, change
- its own deployment, from `deployment/terraform-<app>/`

Besides each app's `<app>.env`, the repo root holds only what every app
shares: the `Dockerfile`, the `Makefile`, the `docker-compose*.yml` files,
`.env` (the ports of every service), and `flow-templates/`.

Each app's demo (`make <app>_demo`) builds every app's image from the current
commit and serves them together through nginx, so one change shows up in every
app at once. Each demo runs as its own compose project, on its own host port,
so demos can run side by side.

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
