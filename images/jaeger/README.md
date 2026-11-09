# Jaeger

[Jaeger](https://www.jaegertracing.io/), the distributed tracing platform (all in one), as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.22.0` | `latest`, `2.22`, `2` |

```sh
jerboa network create app
jerboa run jerboa/jaeger --network app -p 127.0.0.1:4318:4318 -p 127.0.0.1:16686:16686
open http://127.0.0.1:16686/
```

- **In:** OTLP over HTTP on port 4318 and over gRPC on port 4317.
- **Out:** the UI and query API on port 16686; health on port 13133
  (`/status`).
- **Storage:** in memory, up to 100,000 traces: they are gone when the VM
  stops. For other storage, mount your own `/etc/jaeger/config.yaml`.
- **Access:** no authentication. Publish the ports on `127.0.0.1`, or only on
  a private network.

Built from [`images/jaeger`](https://github.com/AitorConS/jerboa-images/tree/main/images/jaeger)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/jaeger` shows it.
