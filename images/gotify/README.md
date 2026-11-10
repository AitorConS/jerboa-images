# Gotify

[Gotify](https://gotify.net/), the server for sending and receiving messages, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.1.1` | `latest`, `3.1`, `3` |

```sh
jerboa network create app
jerboa volume create gotify-data
jerboa run jerboa/gotify --network app -p 127.0.0.1:8080:80 -v gotify-data:/app/data \
  -e GOTIFY_DEFAULTUSER_PASS=<a password>
```

- **First user:** `admin`, with the password in `GOTIFY_DEFAULTUSER_PASS`
  (Gotify's default is `admin`). It is set when the database is created:
  pass it on the first start.
- **Data:** the SQLite database and uploads in `/app/data`. Mount a volume
  there to keep them across VMs.
- Plugins (Go shared objects) are not supported.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/gotify`](https://github.com/AitorConS/jerboa-images/tree/main/images/gotify)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/gotify` shows it.
