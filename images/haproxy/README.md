# HAProxy

[HAProxy](https://www.haproxy.org/), the load balancer and proxy, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.2.26` | `latest`, `3.2`, `3` |
| `3.0.30` | `3.0` |

```sh
jerboa network create app
jerboa run jerboa/haproxy --network app -p 127.0.0.1:8080:80 -p 127.0.0.1:8404:8404
curl http://127.0.0.1:8080/
```

The configuration is `/etc/haproxy/haproxy.cfg`. The default one answers
`/` on port 80 and serves the statistics page (`/stats`) and Prometheus
metrics (`/metrics`) on port 8404. Mount your own configuration on
`/etc/haproxy` (`-v haproxy-conf:/etc/haproxy:ro`).

HAProxy runs as one process in the foreground (`-db`), using threads; keep
`daemon` and `master-worker` out of your configuration, since a unikernel
cannot fork.

Built from [`images/haproxy`](https://github.com/AitorConS/jerboa-images/tree/main/images/haproxy)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/haproxy` shows it.
