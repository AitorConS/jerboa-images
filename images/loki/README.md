# Loki

[Loki](https://grafana.com/oss/loki/), the log aggregation system, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.7.9` | `latest`, `3.7`, `3` |
| `3.6.19` | `3.6` |

```sh
jerboa network create app
jerboa volume create loki-data --size 10G
jerboa run jerboa/loki --network app -p 127.0.0.1:3100:3100 -v loki-data:/var/lib/loki
curl http://127.0.0.1:3100/ready
```

- **Configuration:** `/etc/loki/config.yaml`: a single instance with its
  index and chunks on the filesystem under `/var/lib/loki`, and the write-ahead log
  in `/var/lib/loki/wal`. Mount a volume on `/var/lib/loki` to keep logs across VMs.
- **Pushing logs:** the Loki push API on port 3100, from Promtail, Grafana
  Alloy, Vector, the OpenTelemetry Collector or any HTTP client.
- **Access:** no authentication (`auth_enabled: false`). Publish the port on
  `127.0.0.1`, or only on a private network.
- Usage reporting to Grafana is off.

Built from [`images/loki`](https://github.com/AitorConS/jerboa-images/tree/main/images/loki)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/loki` shows it.
