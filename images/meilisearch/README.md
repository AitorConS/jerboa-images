# Meilisearch

[Meilisearch](https://www.meilisearch.com/), the search engine, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `1.55.0` | `latest`, `1.55`, `1` |

```sh
jerboa network create app
jerboa volume create meili-data --size 10G
jerboa run jerboa/meilisearch --network app -p 127.0.0.1:7700:7700 \
  -v meili-data:/meili_data -e MEILI_MASTER_KEY=<a key of 16 bytes or more>
curl http://127.0.0.1:7700/health
```

- **Data:** `/meili_data`. Mount a volume there to keep it across VMs.
- **Access:** without `MEILI_MASTER_KEY` the API is open to anyone who can
  reach it. Set one (`-e MEILI_MASTER_KEY=...`), and `-e MEILI_ENV=production`
  for production.
- Analytics are off (`--no-analytics`).

Built from [`images/meilisearch`](https://github.com/AitorConS/jerboa-images/tree/main/images/meilisearch)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/meilisearch` shows it.
