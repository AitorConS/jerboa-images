# NATS

[NATS](https://nats.io/), the messaging system, with JetStream, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.15.1` | `latest`, `2.15`, `2` |
| `2.14.8` | `2.14` |

```sh
jerboa network create app
jerboa volume create nats-data
jerboa run jerboa/nats --network app -p 127.0.0.1:4222:4222 -p 127.0.0.1:8222:8222 \
  -v nats-data:/data
nats -s nats://127.0.0.1:4222 pub greetings hello
```

- **Clients** on port 4222, **monitoring** on port 8222 (`/varz`, `/jsz`,
  `/healthz`).
- **JetStream** is on, storing streams in `/data`: mount a volume there to
  keep them across VMs.
- **Access:** no authentication or TLS. Publish the ports on `127.0.0.1`, or
  only on a private network; for accounts and TLS, pass a configuration
  file with `--config`.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/nats`](https://github.com/AitorConS/jerboa-images/tree/main/images/nats)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/nats` shows it.
