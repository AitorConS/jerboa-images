# static-web-server

[static-web-server](https://static-web-server.net/), the small, fast static file server, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.44.1` | `latest`, `2.44`, `2` |

```sh
jerboa network create app
jerboa run jerboa/static-web-server --network app -p 127.0.0.1:8080:80
curl http://127.0.0.1:8080/
```

It serves `/srv` on port 80, with a health endpoint at `/health`. To serve
your own site, mount a volume holding it on `/srv` (`-v site:/srv:ro`).

Built from [`images/static-web-server`](https://github.com/AitorConS/jerboa-images/tree/main/images/static-web-server)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/static-web-server` shows it.
