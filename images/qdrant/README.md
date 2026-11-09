# Qdrant

[Qdrant](https://qdrant.tech/), the vector database, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.20.0` | `latest`, `1.20`, `1` |
| `1.19.2` | `1.19` |

```sh
jerboa network create app
jerboa volume create qdrant-data --size 10G
jerboa run jerboa/qdrant --network app -p 127.0.0.1:6333:6333 -v qdrant-data:/var/lib/qdrant/storage
curl http://127.0.0.1:6333/collections
```

- **API:** REST on port 6333 and gRPC on port 6334. The web dashboard is not
  included.
- **Data:** `/var/lib/qdrant/storage`, snapshots in `/var/lib/qdrant/snapshots`. Mount a
  volume on `/var/lib/qdrant/storage` to keep collections across VMs.
- **Access:** no API key. Set one with `-e QDRANT__SERVICE__API_KEY=...`, or
  publish the ports on `127.0.0.1` only.
- Telemetry is off (`QDRANT__TELEMETRY_DISABLED`).

Built from [`images/qdrant`](https://github.com/AitorConS/jerboa-images/tree/main/images/qdrant)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/qdrant` shows it.
