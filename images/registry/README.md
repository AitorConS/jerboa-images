# Distribution registry

[Distribution registry](https://distribution.github.io/distribution/) (CNCF Distribution), the OCI container image registry, as a [Jerboa](https://github.com/AitorConS/jerboa)
unikernel for linux/amd64 and linux/arm64.

| Version | Also tagged |
|---|---|
| `3.1.2` | `latest`, `3.1`, `3` |

```sh
jerboa network create app
jerboa volume create registry-data --size 20G
jerboa run jerboa/registry --network app -p 127.0.0.1:5000:5000 -v registry-data:/var/lib/registry
docker push 127.0.0.1:5000/my/image:tag
```

- **Storage:** the filesystem, in `/var/lib/registry`. Mount a volume there
  to keep images across VMs.
- **Configuration:** `/etc/distribution/config.yml`; mount your own on
  `/etc/distribution` for authentication, TLS or other storage.
- **Access:** no authentication or TLS: publish the port on `127.0.0.1`,
  where Docker and Podman accept a plain HTTP registry.
- This is a registry for OCI container images, not for Jerboa images.

On Linux hosts, `jerboa stop` cannot yet ask the unikernel to shut down: it
ends the VM, so writes from the last few seconds before it may not have
reached the volume. Give it a few seconds after a write that must be kept.
The image's tests stop it that way on every platform.

Built from [`images/registry`](https://github.com/AitorConS/jerboa-images/tree/main/images/registry)
by GitHub Actions, tested on both platforms and signed with Sigstore:
`jerboa pull` checks the signature on its own, and
`jerboa registry verify jerboa/registry` shows it.
