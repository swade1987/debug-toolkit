# CLAUDE.md design notes

## Purpose

This CLAUDE.md optimizes for one thing: a future agent picking up work on debug-toolkit without re-discovering the two genuinely non-obvious bugs that made building this image harder than it looked (the httping musl timing bug, and the libintl runtime-vs-build-time package trap), and without accidentally reintroducing a mistake already fixed once elsewhere (the unnecessary GCR login on PR builds, first found and fixed on kubernetes-toolkit). The repo is small and single-purpose, so this file stays proportionately small - it isn't trying to be podium's CLAUDE.md.

## Provenance

### Created

- 2026-09-03, in the same session that built the whole repo from scratch (image, CI, supply-chain scaffolding), immediately after the user flagged that CLAUDE.md and DCO enforcement were both missing compared to the sibling repos.
- Sources: the repo's own commit history (`git log`, read fresh, not recalled) and the session's own record of what was actually tested and found - the httping bugs were verified by building and running the image repeatedly, not read from documentation.

### Edits

- 2026-09-03 - initial creation, alongside this design doc. No prior CLAUDE.md existed for this repo.

## Design decisions

- **No bead/AgenC references**, same reasoning as podium's CLAUDE.md: this is a public repo, and a reference to Steve's personal tooling would be dead on arrival for any other reader.
- **The five "constraints that matter" are each tied to a real, verified incident from this repo's own build**, not to generic best-practice advice: the httping timing bug and the libintl runtime dependency were both found by actually running the built image, not by reading a spec; the read-only-rootfs/non-root design and the weekly-rebuild-vs-version-bump distinction are stated as design intent because they're both easy to accidentally undo (e.g., "just make it easier, run as root" or "let's add a version-bump script like kubernetes-toolkit's" would both quietly break something a future reader wouldn't immediately connect back to why); the GCR-login and secrets bullets both encode mistakes or gaps that already happened once in a sibling repo or in this repo's own setup, worth stating so they don't happen again.
- **Considered and rejected: documenting the full httping build recipe (CMake flags, package list) inline.** It's already in the Dockerfile itself, which is the canonical, always-current source - restating it here would just be a second copy that could drift. The CLAUDE.md states the *why* behind the non-obvious parts of that recipe, not the recipe itself.
