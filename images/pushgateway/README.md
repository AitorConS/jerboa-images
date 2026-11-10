# Pushgateway

[Pushgateway](https://github.com/prometheus/pushgateway), the Prometheus push acceptor for batch jobs, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.11.4` | `latest`, `1.11`, `1` |

```sh
jerboa network create app
jerboa run jerboa/pushgateway --network app -p 127.0.0.1:9091:9091
echo 'backup_duration_seconds 42' | curl --data-binary @- http://127.0.0.1:9091/metrics/job/backup
```

Pushed metrics are saved to `/data/metrics` every 5 seconds: mount a volume
on `/data` to keep them across VMs. There is no authentication: publish the
port on `127.0.0.1`, or only on a private network.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/pushgateway`](https://github.com/AitorConS/jerboa-images/tree/main/images/pushgateway)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/pushgateway` shows it.
