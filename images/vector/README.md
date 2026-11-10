# Vector

[Vector](https://vector.dev/), the observability data pipeline, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.60.0` | `latest`, `0.60` |

```sh
jerboa network create app
jerboa run jerboa/vector --network app -p 127.0.0.1:8080:8080
curl -d 'hello' http://127.0.0.1:8080/
jerboa logs <vm>
```

- **Configuration:** `/etc/vector/vector.yaml` takes events over HTTP on port
  8080 and prints them to the console as JSON (`jerboa logs`). Mount your
  own, with your sources and sinks, on `/etc/vector`.
- **API:** port 8686 (`/health`). Data for disk buffers goes to
  `/var/lib/vector`.
- Sources that run programs (`exec`) or read the host (`docker_logs`,
  `journald`, `host_metrics`) do not apply inside a unikernel.

Built from [`images/vector`](https://github.com/AitorConS/jerboa-images/tree/main/images/vector)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/vector` shows it.
