# Security Policy

## Supported versions

debug-toolkit ships one rolling `latest` image; there's no long-term-support branch to track. Security fixes land on `main` and are published as the next tagged release, and the image itself is rebuilt weekly to pick up current Alpine package versions.

## Reporting a vulnerability

Please report security issues privately rather than opening a public GitHub issue: use [GitHub's private vulnerability reporting](https://github.com/swade1987/debug-toolkit/security/advisories/new) for this repository (Security tab → Report a vulnerability).

Include what you'd include in any good bug report: the affected version or commit, what you found, and how to reproduce it. We'll acknowledge new reports within 5 business days and aim to have a fix or mitigation plan within 30 days, depending on severity.

## Scope

This image is meant to be thrown up as an ephemeral debug pod or attached as an ephemeral container to an existing pod - reports about the image build, the bundled tools' packaging, or the CI/release pipeline are in scope. It intentionally runs as non-root with no capabilities of its own; reports that it can't capture packets or send ICMP without the pod granting `NET_RAW` describe documented, intended behavior, not a vulnerability.
