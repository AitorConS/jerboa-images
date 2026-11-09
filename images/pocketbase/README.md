# PocketBase

[PocketBase](https://pocketbase.io/), the backend in one file: database, auth, files and admin UI, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `0.40.6` | `latest`, `0.40` |

```sh
jerboa network create app
jerboa volume create pb-data
jerboa run jerboa/pocketbase --network app -p 127.0.0.1:8090:8090 -v pb-data:/pb_data
jerboa logs <vm>    # the link to create the first superuser
```

- **First start:** the console (`jerboa logs`) shows a link to create the
  first superuser; open it, with the host and port you published.
- **Data:** the database and uploaded files in `/pb_data`. Mount a volume
  there to keep them across VMs. Static files are served from `/pb_public`,
  JavaScript migrations and hooks are read from `/pb_migrations` and
  `/pb_hooks`: mount volumes there to use them.

Built from [`images/pocketbase`](https://github.com/AitorConS/jerboa-images/tree/main/images/pocketbase)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/pocketbase` shows it.
