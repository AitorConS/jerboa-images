# Valkey

[Valkey](https://valkey.io/), the in-memory data store, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `9.0.6` | `latest`, `9.0`, `9` |
| `8.1.10` | `8.1`, `8` |
| `7.2.14` | `7.2`, `7` |

```sh
jerboa network create app
jerboa run jerboa/valkey --network app -p 127.0.0.1:6379:6379
valkey-cli -h 127.0.0.1 ping
```

- **Persistence:** none. Data is kept in memory (`--save ""`,
  `--appendonly no`), so it is gone when the VM stops: use it as a cache.
- **Access:** it listens on every interface without a password
  (`--protected-mode no`). Publish the port on `127.0.0.1`, or only on a
  private network.

Built from [`images/valkey`](https://github.com/AitorConS/jerboa-images/tree/main/images/valkey)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/valkey` shows it.
