# Redis

[Redis](https://redis.io/), the in-memory data store, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `7.2.16` | `latest`, `7.2`, `7` |

```sh
jerboa network create app
jerboa run jerboa/redis --network app -p 127.0.0.1:6379:6379
redis-cli -h 127.0.0.1 ping
```

- **Persistence:** none. Data is kept in memory (`--save ""`,
  `--appendonly no`), so it is gone when the VM stops: use it as a cache.
- **Access:** it listens on every interface without a password
  (`--protected-mode no`). Publish the port on `127.0.0.1`, or only on a
  private network.

Built from [`images/redis`](https://github.com/AitorConS/jerboa-images/tree/main/images/redis)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/redis` shows it.
