# Jerboa official images

The official images under `jerboa/` on [registry.jerboa.dev](https://hub.jerboa.dev/jerboa),
for [Jerboa](https://github.com/AitorConS/jerboa): unikernels built for
linux/amd64 and linux/arm64 from Jerboa's first-party packages.

| Image | Versions | |
|---|---|---|
| [`jerboa/adguard-home`](images/adguard-home) | 0.107.79 | The network-wide ad and tracker blocking DNS server |
| [`jerboa/alertmanager`](images/alertmanager) | 0.34.1 | The alert router of Prometheus |
| [`jerboa/blackbox-exporter`](images/blackbox-exporter) | 0.29.1 | The Prometheus prober for HTTP, TCP and DNS endpoints |
| [`jerboa/coredns`](images/coredns) | 1.15.0, 1.14.7 | The DNS server |
| [`jerboa/etcd`](images/etcd) | 3.7.3, 3.6.16, 3.5.35 | The distributed key-value store |
| [`jerboa/gotify`](images/gotify) | 3.1.1 | The server for sending and receiving messages |
| [`jerboa/haproxy`](images/haproxy) | 3.2.26, 3.0.30 | The load balancer and proxy |
| [`jerboa/httpbin`](images/httpbin) | 2.26.0 | The HTTP request and response service |
| [`jerboa/jaeger`](images/jaeger) | 2.22.0 | The distributed tracing platform (all in one, in memory) |
| [`jerboa/loki`](images/loki) | 3.7.9, 3.6.19 | The log aggregation system (single binary) |
| [`jerboa/mailpit`](images/mailpit) | 1.32.0 | The email and SMTP testing tool |
| [`jerboa/memcached`](images/memcached) | 1.6.45 | The memory object cache |
| [`jerboa/nats`](images/nats) | 2.15.1, 2.14.8 | The messaging system, with JetStream |
| [`jerboa/nginx`](images/nginx) | 1.30.6, 1.31.8 | The web server, serving static files as a Jerboa unikernel |
| [`jerboa/ntfy`](images/ntfy) | 2.34.0 | The HTTP-based publish-subscribe notification service |
| [`jerboa/openbao`](images/openbao) | 2.7.1, 2.6.4 | The open source secrets manager |
| [`jerboa/otel-collector`](images/otel-collector) | 0.163.2 | The telemetry pipeline |
| [`jerboa/pocketbase`](images/pocketbase) | 0.40.6 | A backend in one file (database, auth, files and admin UI) |
| [`jerboa/prometheus`](images/prometheus) | 3.15.1, 3.13.5 | The monitoring system and time series database |
| [`jerboa/pushgateway`](images/pushgateway) | 1.11.4 | The Prometheus push acceptor for batch jobs |
| [`jerboa/qdrant`](images/qdrant) | 1.20.0, 1.19.2 | The vector database |
| [`jerboa/redis`](images/redis) | 7.2.16 | The in-memory data store |
| [`jerboa/registry`](images/registry) | 3.1.2 | The CNCF Distribution registry for OCI container images |
| [`jerboa/seaweedfs`](images/seaweedfs) | 4.51 | The distributed file and object store (all in one) |
| [`jerboa/static-web-server`](images/static-web-server) | 2.44.1 | A small and fast static file server |
| [`jerboa/traefik`](images/traefik) | 3.7.16 | The reverse proxy and load balancer |
| [`jerboa/valkey`](images/valkey) | 9.0.6, 8.1.10, 7.2.14 | The in-memory data store |
| [`jerboa/vector`](images/vector) | 0.60.0 | The observability data pipeline |
| [`jerboa/victoria-metrics`](images/victoria-metrics) | 1.154.1 | The time series database (single node) |
| [`jerboa/zot`](images/zot) | 2.1.22 | The OCI-native container image registry |

```sh
jerboa pull jerboa/redis
```

## How they are published

[`.github/workflows/publish.yml`](.github/workflows/publish.yml) builds each
image, at each of its versions, for both platforms, tests it (below), then
publishes it from `main`:
- `jerboa/<name>:<version>-amd64` and `:<version>-arm64`, one per platform;
- `jerboa/<name>:<version>`, an image index of both, so a pull picks the
  host's platform, and the same index as `:<major>.<minor>` and `:<major>`
  when it is the newest of that line, and `:latest` for the newest version.

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

## How they are tested

`scripts/test.sh <name> [version]` boots the image for this host's platform
and runs its `check.sh`:

1. **ready:** it boots, its ports are published on `127.0.0.1`, and it is
   ready within 120 seconds;
2. **exercise:** its real work through its own protocol: Redis commands,
   SMTP, DNS over UDP, the OCI distribution API, NATS publish and subscribe,
   OpenBao's init, unseal and secrets, searches, traces and so on;
3. **stop:** it stops cleanly;
4. **data:** for an image that keeps data (`DATA` in `image.env`), it boots
   with a new volume on that directory, writes, is replaced by a new VM on
   the same volume, and what it wrote must still be there;
5. **console:** a fault signal, a kernel panic, a failed fork or an
   unimplemented system call on the console fails the test.

CI runs it on linux/amd64 (KVM on GitHub's runners) for every image and
version; linux/arm64 is run the same way on Apple Silicon before a new image
or version is added.

## An image

```
images/<name>/
  image.env        versions (the newest first), platforms, hub description,
                   ports, and the data directory if it keeps data
  unikernel.toml   how it is built and run; @VERSION@ is the version
  check.sh         its tests: ready, exercise, and write_data/read_data
  rootfs/          files it adds to the image (configuration, default pages)
  README.md        shown on the hub
base/rootfs/       files every image gets: /etc/hosts and CA certificates
```

`scripts/build.sh <name> [version]` builds it, `scripts/test.sh <name>
[version]` tests it on this host, and `scripts/publish.sh <name> [version]`
publishes it. Without a version they take the newest.

## License

Apache 2.0, like Jerboa. Each image's software keeps its own license.
