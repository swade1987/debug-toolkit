# debug-toolkit

[![image](https://github.com/swade1987/debug-toolkit/actions/workflows/image.yml/badge.svg)](https://github.com/swade1987/debug-toolkit/actions/workflows/image.yml)
[![commit-lint](https://github.com/swade1987/debug-toolkit/actions/workflows/commit-lint.yaml/badge.svg)](https://github.com/swade1987/debug-toolkit/actions/workflows/commit-lint.yaml)
[![pr-lint](https://github.com/swade1987/debug-toolkit/actions/workflows/pr-lint.yml/badge.svg)](https://github.com/swade1987/debug-toolkit/actions/workflows/pr-lint.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/swade1987/debug-toolkit/badge)](https://scorecard.dev/viewer/?uri=github.com/swade1987/debug-toolkit)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A minimal, non-root, read-only-rootfs-friendly container for debugging HTTP and network issues from inside a Kubernetes cluster - `ab`, `httping`, `curl`, `dig`, `tcpdump` and friends, instead of grabbing a random image off Docker Hub to borrow one command from.

## Why this exists

[podium](https://github.com/platformfix/podium) and [kubernetes-toolkit](https://github.com/swade1987/kubernetes-toolkit) both cover general Kubernetes work, but neither ships HTTP load/latency tools - if you need `ab` or `httping` from inside a cluster, the usual move is to throw up a random throwaway pod and hope it has what you need. This is that pod, purpose-built and trustworthy instead.

## Usage

Ephemeral, thrown away when you're done - this image isn't meant to be deployed as a long-running pod:

```bash
kubectl run debug --rm -it --image=eu.gcr.io/swade1987/debug-toolkit -- bash
```

To debug an *existing* pod's network namespace directly, attach an ephemeral debug container to it instead:

```bash
kubectl debug -it <pod-name> --image=eu.gcr.io/swade1987/debug-toolkit --target=<container-name> -- bash
```

### Read-only root filesystem

The image runs fine with `readOnlyRootFilesystem: true`, but that setting covers the *whole* filesystem, `/tmp` included - mount an `emptyDir` there or tools that need scratch space (packet captures, temp files) will fail:

```yaml
securityContext:
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 10001
volumeMounts:
  - name: tmp
    mountPath: /tmp
volumes:
  - name: tmp
    emptyDir: {}
```

### Packet capture and ICMP tools

`tcpdump` and `mtr` need raw-socket access the image doesn't grant by default (it isn't root, and carries no capabilities of its own). Add what you need at the pod level:

```yaml
securityContext:
  capabilities:
    add: ["NET_RAW"]   # tcpdump, and mtr's ICMP mode
```

## What's in the image

- [ab](https://httpd.apache.org/docs/2.4/programs/ab.html) (ApacheBench) - HTTP load testing
- [httping](https://github.com/folkertvanheusden/HTTPing) - HTTP-level ping/latency, built from source (see below)
- curl, wget
- dig / nslookup / host (bind-tools)
- netcat (netcat-openbsd)
- tcpdump
- mtr, iperf3, socat, jq
- bash

### httping is built from source, with one patch

Alpine doesn't package `httping` at all (checked both the stable and edge/community repos), so the [Dockerfile](Dockerfile) builds it from the upstream source. It also carries one small patch: httping's own time-measurement function mixes a deprecated, unreliable field of `gettimeofday(2)` into every timestamp, which on musl libc (this image's C library) produces wildly wrong - sometimes negative - round-trip times. Verified directly against a real host before and after; the Dockerfile's builder stage explains the fix inline.

## Supply chain security

Every image push gets a signed build provenance attestation and an attested SBOM (GitHub's own Sigstore-backed [artifact attestations](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds)), verifiable with:

```bash
gh attestation verify oci://eu.gcr.io/swade1987/debug-toolkit:latest --owner swade1987
```

The image is rebuilt weekly (in addition to every push to `main`) to pick up current Alpine package versions even when the Dockerfile itself hasn't changed - Dependabot separately tracks the base image's own digest. The repo runs an [OpenSSF Scorecard](https://scorecard.dev/) check on every push (badge above). See [SECURITY.md](SECURITY.md) to report a vulnerability.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Commits and pull request titles must follow [Conventional Commits](https://www.conventionalcommits.org/); this is enforced by CI.

## License

[MIT](LICENSE)
