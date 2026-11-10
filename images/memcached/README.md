# memcached

[memcached](https://memcached.org/), the memory object cache, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.6.45` | `latest`, `1.6`, `1` |

```sh
jerboa network create app
jerboa run jerboa/memcached --network app -p 127.0.0.1:11211:11211
printf 'stats\r\nquit\r\n' | nc 127.0.0.1 11211
```

It listens on TCP port 11211 (UDP is off) with 128 MB for items and up to
1024 connections. There is no authentication: publish the port on
`127.0.0.1`, or only on a private network.

Built from [`images/memcached`](https://github.com/AitorConS/jerboa-images/tree/main/images/memcached)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/memcached` shows it.
