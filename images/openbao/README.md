# OpenBao

[OpenBao](https://openbao.org/), the secrets manager (a fork of HashiCorp Vault, under the MPL), as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.7.1` | `latest`, `2.7`, `2` |
| `2.6.4` | `2.6` |

```sh
jerboa network create app
jerboa volume create openbao-data
jerboa run jerboa/openbao --network app -p 127.0.0.1:8200:8200 -v openbao-data:/var/lib/openbao
export BAO_ADDR=http://127.0.0.1:8200
bao operator init
```

- **Storage:** integrated (Raft) storage in `/var/lib/openbao`, a single node.
  Mount a volume there: without one, every new VM starts uninitialized.
- **First start:** initialize it (`bao operator init`) and unseal it with
  the keys it prints, after every start. Keep the keys and the root token
  safe.
- **TLS is off** in `/etc/openbao/config.hcl`: publish the port on
  `127.0.0.1` only, or mount your own configuration with TLS on
  `/etc/openbao`.
- Memory locking (`mlock`) does not apply: a unikernel has no swap.

Built from [`images/openbao`](https://github.com/AitorConS/jerboa-images/tree/main/images/openbao)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/openbao` shows it.
