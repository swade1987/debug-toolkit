# Contributing

Thanks for considering a contribution to debug-toolkit.

## Before you start

Open an issue for anything beyond a small fix, so we can agree on the approach before you put time into it.

## Commits and pull requests

- Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/). This is enforced by CI (`commit-lint`).
- Pull request titles must also follow Conventional Commits. CI (`pr-lint`) checks this too, since a squash merge takes its message from the PR title.
- Keep commits small and focused; a pull request with five commits that each do one thing is easier to review than one commit that does five things.

## Testing changes locally

```bash
hadolint Dockerfile
docker build -t debug-toolkit:dev .
docker run --rm --read-only --tmpfs /tmp --user 10001 debug-toolkit:dev bash
```

## Reporting issues

Open an issue on GitHub with what you expected, what happened instead, and how to reproduce it.
