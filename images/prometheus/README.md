# Prometheus

[Prometheus](https://prometheus.io/), the monitoring system and time series database, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.15.1` | `latest`, `3.15`, `3` |
| `3.13.5` | `3.13` |

```sh
jerboa network create app
jerboa volume create prometheus-data
jerboa run jerboa/prometheus --network app -p 127.0.0.1:9090:9090 \
  -v prometheus-data:/var/lib/prometheus
curl 'http://127.0.0.1:9090/api/v1/query?query=up'
```

- **Configuration:** `/etc/prometheus/prometheus.yml`, which scrapes
  Prometheus itself. Mount your own on `/etc/prometheus`
  (`-v prometheus-conf:/etc/prometheus:ro`); `POST /-/reload` reloads it.
- **Data:** `/var/lib/prometheus`. Mount a volume there to keep it across VMs.
- **Access:** the API and the web UI have no authentication. Publish the port
  on `127.0.0.1`, or only on a private network.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/prometheus`](https://github.com/AitorConS/jerboa-images/tree/main/images/prometheus)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/prometheus` shows it.
