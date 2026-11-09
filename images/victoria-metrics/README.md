# VictoriaMetrics

[VictoriaMetrics](https://victoriametrics.com/), the time series database (single node), as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.154.1` | `latest`, `1.154`, `1` |

```sh
jerboa network create app
jerboa volume create vm-data --size 10G
jerboa run jerboa/victoria-metrics --network app -p 127.0.0.1:8428:8428 -v vm-data:/data
curl -d 'temperature{room="lab"} 21.5' http://127.0.0.1:8428/api/v1/import/prometheus
```

- **Data:** `/data`, kept for a month (`-retentionPeriod=1`). Mount a volume
  there to keep it across VMs.
- **Ingestion and queries:** Prometheus remote write, the Prometheus
  exposition format, InfluxDB line protocol, and PromQL/MetricsQL on port
  8428.
- **Access:** no authentication. Publish the port on `127.0.0.1`, or only on
  a private network.

Built from [`images/victoria-metrics`](https://github.com/AitorConS/jerboa-images/tree/main/images/victoria-metrics)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/victoria-metrics` shows it.
