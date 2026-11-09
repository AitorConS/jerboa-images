# AdGuard Home

[AdGuard Home](https://adguard.com/adguard-home/overview.html), the network-wide ad and tracker blocking DNS server, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.107.79` | `latest`, `0.107` |

```sh
jerboa network create app
jerboa volume create adguard-work
jerboa volume create adguard-conf
jerboa run jerboa/adguard-home --network app -p 127.0.0.1:3000:3000 -p 53:53/udp \
  -v adguard-work:/opt/adguardhome/work -v adguard-conf:/opt/adguardhome/conf
open http://127.0.0.1:3000/
```

- **First start:** open port 3000 to run the setup wizard; keep the web
  interface on port 3000 and DNS on port 53.
- **Data:** the configuration in `/opt/adguardhome/conf` and the query log,
  statistics and filters in `/opt/adguardhome/work`. Mount volumes on both
  to keep them across VMs.
- DNS over UDP on port 53; DHCP is not available in a unikernel. Automatic
  updates are off: pull a newer image instead.

Built from [`images/adguard-home`](https://github.com/AitorConS/jerboa-images/tree/main/images/adguard-home)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/adguard-home` shows it.
