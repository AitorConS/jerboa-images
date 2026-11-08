# Jerboa official images

The official images under `jerboa/` on [registry.jerboa.dev](https://hub.jerboa.dev/jerboa),
for [Jerboa](https://github.com/AitorConS/jerboa): unikernels built for
linux/amd64 and linux/arm64 from Jerboa's first-party packages.

| Image | Version | |
|---|---|---|
| [`jerboa/redis`](images/redis) | 7.2.16 | In-memory data store |
| [`jerboa/nginx`](images/nginx) | 1.30.6 | Web server, static files |
| [`jerboa/caddy`](images/caddy) | 2.11.7 | Web server, static files |

```sh
jerboa pull jerboa/redis
```

## How they are published

[`.github/workflows/publish.yml`](.github/workflows/publish.yml) builds each
image for both platforms, boots it and checks that it answers, then
publishes it from `main`:
- `jerboa/<name>:<version>-amd64` and `:<version>-arm64`, one per platform;
- `jerboa/<name>:<version>` and `:latest`, an image index of both, so a pull
  picks the host's platform.

The registry trusts this workflow on `main` as a publisher of the `jerboa`
namespace: it pushes with the job's OIDC token, with no stored credential.
Every push is signed keyless with [Sigstore](https://www.sigstore.dev/),
with attestations of its provenance (this repository, commit, workflow and
run) and its SBOM.

`jerboa pull` only accepts `jerboa/` images signed by
`AitorConS/jerboa-images/.github/workflows/publish.yml` on `refs/heads/main`.
To check one yourself:

```sh
jerboa registry verify jerboa/redis
```

A weekly run rebuilds everything, to pick up new package and toolset builds.
Builds are deterministic, so an image whose disk did not change is not
pushed or signed again.

Every run scans the images' SBOMs with [grype](https://github.com/anchore/grype)
(`scripts/scan.sh`; the report is on the run's summary). On `main`, critical
or high vulnerabilities open an issue, once per image and version, and are
sent to Telegram.

## An image

```
images/<name>/
  image.env        version, platforms, hub description, and how to check it answers
  unikernel.toml   how it is built and run
  rootfs/          files it adds to the image (configuration, default pages)
  README.md        shown on the hub
```

`scripts/build.sh <name>` builds it, `scripts/test.sh <name>` boots it for
this host and checks it (`CHECK=http` with the text the page must contain, or
`CHECK=redis`), and `scripts/publish.sh <name>` publishes it.

## License

Apache 2.0, like Jerboa. Each image's software keeps its own license.
