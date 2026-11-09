# Alertmanager

[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/), the alert router of Prometheus, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.34.1` | `latest`, `0.34` |

```sh
jerboa network create app
jerboa volume create alertmanager-data
jerboa run jerboa/alertmanager --network app -p 127.0.0.1:9093:9093 \
  -v alertmanager-data:/var/lib/alertmanager
curl http://127.0.0.1:9093/api/v2/status
```

- **Configuration:** `/etc/alertmanager/alertmanager.yml`, which receives
  alerts and sends them nowhere. Mount your own, with your receivers, on
  `/etc/alertmanager` (`-v alertmanager-conf:/etc/alertmanager:ro`).
- **Data:** silences and notification state in `/var/lib/alertmanager`; mount a
  volume there to keep them. A single instance: clustering is off.
- **Access:** no authentication. Publish the port on `127.0.0.1`, or only on
  a private network.

Built from [`images/alertmanager`](https://github.com/AitorConS/jerboa-images/tree/main/images/alertmanager)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/alertmanager` shows it.
