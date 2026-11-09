# ntfy

[ntfy](https://ntfy.sh/), the HTTP-based publish-subscribe notification service, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.34.0` | `latest`, `2.34`, `2` |

```sh
jerboa network create app
jerboa run jerboa/ntfy --network app -p 127.0.0.1:8080:80
curl -d 'Backup done' http://127.0.0.1:8080/mytopic
```

Messages are cached for 12 hours in `/var/cache/ntfy/cache.db`: mount a
volume on `/var/cache/ntfy` to keep them across VMs. Anyone who can reach the
port can publish and subscribe: publish it on `127.0.0.1`, or configure
access control with `--auth-file` and `--auth-default-access`.

Built from [`images/ntfy`](https://github.com/AitorConS/jerboa-images/tree/main/images/ntfy)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/ntfy` shows it.
