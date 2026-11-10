# CoreDNS

[CoreDNS](https://coredns.io/), the DNS server, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.15.0` | `latest`, `1.15`, `1` |
| `1.14.7` | `1.14` |

```sh
jerboa network create app
jerboa run jerboa/coredns --network app -p 127.0.0.1:1053:53/udp
dig @127.0.0.1 -p 1053 example.jerboa.test
```

- **Configuration:** `/etc/coredns/Corefile` answers names from its `hosts`
  block (`example.jerboa.test` as an example) and the `whoami` plugin for
  anything else. Mount your own Corefile on `/etc/coredns`, for example with
  `forward . 9.9.9.9` to resolve other names.
- **Ports:** DNS over UDP on port 53, health on port 8080 (`/health`),
  readiness on port 8181 (`/ready`) and Prometheus metrics on port 9153.

Built from [`images/coredns`](https://github.com/AitorConS/jerboa-images/tree/main/images/coredns)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/coredns` shows it.
