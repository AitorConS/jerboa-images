# Blackbox exporter

[Blackbox exporter](https://github.com/prometheus/blackbox_exporter), the Prometheus prober for HTTP, TCP, DNS and ICMP endpoints, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.29.1` | `latest`, `0.29` |

```sh
jerboa network create app
jerboa run jerboa/blackbox-exporter --network app -p 127.0.0.1:9115:9115
curl 'http://127.0.0.1:9115/probe?target=https://jerboa.dev&module=http_2xx'
```

Modules `http_2xx`, `http_post_2xx`, `tcp_connect` and `dns_udp` are in
`/etc/blackbox_exporter/config.yml`; mount your own on
`/etc/blackbox_exporter`. ICMP probes need raw sockets and are not included.

Built from [`images/blackbox-exporter`](https://github.com/AitorConS/jerboa-images/tree/main/images/blackbox-exporter)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/blackbox-exporter` shows it.
