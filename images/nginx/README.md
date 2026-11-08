# nginx

[nginx](https://nginx.org/) 1.30, serving static files, as a
[Jerboa](https://github.com/AitorConS/jerboa) unikernel for linux/amd64 and
linux/arm64.

```sh
jerboa network create app
jerboa run jerboa/nginx --network app -p 127.0.0.1:8080:80
curl http://127.0.0.1:8080/
```

It serves `/etc/nginx/html` on port 80 with the configuration in
`/etc/nginx/conf/nginx.conf`: one process in the foreground, temporary files
in `/tmp`, errors on the console. To serve your own site, mount a volume
holding it on `/etc/nginx/html` (`-v site:/etc/nginx/html:ro`).

The package is built without the rewrite and gzip modules.

Built from [`images/nginx`](https://github.com/AitorConS/jerboa-images/tree/main/images/nginx)
by GitHub Actions and signed with Sigstore: `jerboa pull` checks the
signature on its own, and `jerboa registry verify jerboa/nginx` shows it.
