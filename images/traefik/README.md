# Traefik

[Traefik](https://traefik.io/traefik/), the reverse proxy and load balancer, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.7.16` | `latest`, `3.7`, `3` |

```sh
jerboa network create app
jerboa volume create traefik-routes
jerboa run jerboa/traefik --network app -p 80:80 -p 127.0.0.1:8080:8080 \
  -v traefik-routes:/etc/traefik/dynamic
curl http://127.0.0.1:8080/api/overview
```

- **Entry points:** `web` on port 80 for your routes, and `traefik` on port
  8080 for the API, the dashboard (`/dashboard/`) and `/ping`.
- **Routes:** the file provider reads `/etc/traefik/dynamic`, empty in the
  image: mount a volume with your routes there. Read when Traefik starts.
- **Access:** the API and dashboard on port 8080 have no authentication
  (`--api.insecure`). Publish that port on `127.0.0.1` only.
- There is no Docker or Kubernetes provider: a unikernel has no Docker socket.

Built from [`images/traefik`](https://github.com/AitorConS/jerboa-images/tree/main/images/traefik)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/traefik` shows it.
