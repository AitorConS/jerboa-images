# etcd

[etcd](https://etcd.io/), the distributed, reliable key-value store, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.7.3` | `latest`, `3.7`, `3` |
| `3.6.16` | `3.6` |
| `3.5.35` | `3.5` |

```sh
jerboa network create app
jerboa volume create etcd-data
jerboa run jerboa/etcd --network app -p 127.0.0.1:2379:2379 -v etcd-data:/etcd-data
etcdctl --endpoints=http://127.0.0.1:2379 put greeting hello
```

- **One member:** a single-node cluster named `jerboa`, with clients on port
  2379 (gRPC and the JSON gateway) and peers on `127.0.0.1:2380` only.
- **Data:** `/etcd-data`. Mount a volume there to keep it across VMs.
- **Address:** it advertises `http://127.0.0.1:2379` to clients; pass
  `--advertise-client-urls` with the address clients use if they look it up.
- **Access:** no authentication or TLS. Publish the port on `127.0.0.1`, or
  only on a private network.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/etcd`](https://github.com/AitorConS/jerboa-images/tree/main/images/etcd)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/etcd` shows it.
