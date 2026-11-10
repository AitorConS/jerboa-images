# Mailpit

[Mailpit](https://mailpit.axllent.org/), the email and SMTP testing tool, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.32.0` | `latest`, `1.32`, `1` |

```sh
jerboa network create app
jerboa run jerboa/mailpit --network app -p 127.0.0.1:1025:1025 -p 127.0.0.1:8025:8025
open http://127.0.0.1:8025/
```

Point your application's SMTP at port 1025 and read what it sends in the web
UI or API on port 8025. Messages are stored in `/data/mailpit.db`: mount a
volume on `/data` to keep them. There is no authentication: publish the
ports on `127.0.0.1` only.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/mailpit`](https://github.com/AitorConS/jerboa-images/tree/main/images/mailpit)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/mailpit` shows it.
