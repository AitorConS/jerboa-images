# OpenTelemetry Collector

[OpenTelemetry Collector](https://opentelemetry.io/docs/collector/), the vendor-neutral telemetry pipeline (core distribution), as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.163.2` | `latest`, `0.163` |

```sh
jerboa network create app
jerboa run jerboa/otel-collector --network app -p 127.0.0.1:4318:4318
```

- **Configuration:** `/etc/otelcol/config.yaml` receives traces, metrics and
  logs over OTLP (HTTP on port 4318, gRPC on port 4317) and prints them to
  the console (`jerboa logs`). Mount your own, with your exporters, on
  `/etc/otelcol`.
- **Health:** port 13133.
- This is the core distribution: its components are listed on
  [GitHub](https://github.com/open-telemetry/opentelemetry-collector-releases/tree/main/distributions/otelcol).

Built from [`images/otel-collector`](https://github.com/AitorConS/jerboa-images/tree/main/images/otel-collector)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/otel-collector` shows it.
