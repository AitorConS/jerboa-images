# Base files

`rootfs/` goes into every image, under the image's own `rootfs/` (which wins
where both have a file):

- `etc/hosts`: `localhost` for programs that listen on or connect to it by
  name. A unikernel has no resolver configuration of its own for it.
- `etc/ssl/certs/ca-certificates.crt`: Mozilla's CA certificates, as
  extracted by curl: `cacert-2026-10-20.pem`, SHA-256
  `796f1389bfea13c0ed78f663b765baaff54a508e5483786bd6ece73c5e3e3cbe`, from
  <https://curl.se/docs/caextract.html>. Programs that make TLS connections
  (Go, Rust and OpenSSL alike) read it from this path.
