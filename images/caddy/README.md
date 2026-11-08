# Caddy

[Caddy](https://caddyserver.com/) 2.7, serving static files, as a
[Jerboa](https://github.com/AitorConS/jerboa) unikernel for linux/amd64 and
linux/arm64.

```sh
jerboa network create app
jerboa run jerboa/caddy --network app -p 127.0.0.1:8080:80
curl http://127.0.0.1:8080/
```

It runs `/etc/caddy/Caddyfile`, which serves `/srv` on port 80 with the admin
API and automatic HTTPS off. Mount a volume on `/srv` for your own site, or
on `/etc/caddy` for your own Caddyfile. Caddy keeps its data in `/data` and
its configuration in `/config`.

Built from [`images/caddy`](https://github.com/AitorConS/jerboa-images/tree/main/images/caddy)
by GitHub Actions and signed with Sigstore: `jerboa pull` checks the
signature on its own, and `jerboa registry verify jerboa/caddy` shows it.
