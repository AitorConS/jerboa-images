# httpbin

[httpbin](https://github.com/mccutchen/go-httpbin) (go-httpbin), the HTTP request and response service, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `2.26.0` | `latest`, `2.26`, `2` |

```sh
jerboa network create app
jerboa run jerboa/httpbin --network app -p 127.0.0.1:8080:8080
curl http://127.0.0.1:8080/get
```

It answers on port 8080 with the endpoints of [httpbin.org](https://httpbin.org/):
echoing requests, chosen status codes, redirects, delays and more. Useful for
testing HTTP clients and proxies.

Built from [`images/httpbin`](https://github.com/AitorConS/jerboa-images/tree/main/images/httpbin)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/httpbin` shows it.
