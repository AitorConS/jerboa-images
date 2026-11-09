# zot

[zot](https://zotregistry.dev/), the OCI-native container image registry, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.1.22` | `latest`, `2.1`, `2` |

```sh
jerboa network create app
jerboa volume create zot-data --size 20G
jerboa run jerboa/zot --network app -p 127.0.0.1:5000:5000 -v zot-data:/var/lib/registry
oras push 127.0.0.1:5000/hello:v1 README.md
```

- **Storage:** `/var/lib/registry`, with deduplication and garbage
  collection. Mount a volume there to keep images across VMs.
- **Configuration:** `/etc/zot/config.json`; mount your own on `/etc/zot` for
  authentication, TLS or extensions.
- **Access:** no authentication or TLS: publish the port on `127.0.0.1` only.

Built from [`images/zot`](https://github.com/AitorConS/jerboa-images/tree/main/images/zot)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/zot` shows it.
