# Caddy

[Caddy](https://caddyserver.com/) 2.11, serving static files, as a
[Jerboa](https://github.com/AitorConS/jerboa) unikernel for linux/amd64 and
linux/arm64.

```sh
jerboa network create app
jerboa run jerboa/caddy --network app -p 127.0.0.1:8080:80
curl http://127.0.0.1:8080/
```

It serves `/srv` over plain HTTP on port 80 with the Caddyfile in
`/etc/caddy/Caddyfile`. The admin API, automatic HTTPS and the saved
configuration are off, and Caddy keeps its data under `/tmp`. To serve your
own site, mount a volume holding it on `/srv` (`-v site:/srv:ro`). To change
the configuration, mount one holding a `Caddyfile` on `/etc/caddy`.

Built from [`images/caddy`](https://github.com/AitorConS/jerboa-images/tree/main/images/caddy)
by GitHub Actions and signed with Sigstore: `jerboa pull` checks the
signature on its own, and `jerboa registry verify jerboa/caddy` shows it.
