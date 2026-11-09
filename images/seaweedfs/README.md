# SeaweedFS

[SeaweedFS](https://github.com/seaweedfs/seaweedfs), the distributed file and object store, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `4.51` | `latest`, `4` |

```sh
jerboa network create app
jerboa volume create seaweedfs-data --size 20G
jerboa run jerboa/seaweedfs --network app -v seaweedfs-data:/data \
  -p 127.0.0.1:8888:8888 -p 127.0.0.1:8333:8333
curl -F file=@notes.txt http://127.0.0.1:8888/docs/
```

- **One process** runs the master (port 9333), a volume server (port 8080),
  the filer (port 8888) and the S3 gateway (port 8333).
- **Data:** `/data`. Mount a volume there to keep files across VMs.
- **Access:** no authentication: publish the ports on `127.0.0.1`, or only
  on a private network. Volume servers advertise `127.0.0.1`, so clients
  that follow volume locations must run on the same host.

Built from [`images/seaweedfs`](https://github.com/AitorConS/jerboa-images/tree/main/images/seaweedfs)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/seaweedfs` shows it.
