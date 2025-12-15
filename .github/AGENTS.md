---
parent: [AGENTS.md](../AGENTS.md)
---

# GitHub Workflows

## Workflows

| File | Trigger | Purpose |
|------|---------|---------|
| `ci.yml` | Push to `dev`, PRs to `main` | Shellcheck, tests, dry-run |
| `claude.yml` | @claude mentions | AI assistance in issues/PRs |
| `claude-code-review.yml` | PR opened/updated | Automated code review |

## CI Jobs

| Job | What it Checks |
|-----|----------------|
| `shellcheck` | Lints `.sh` files at warning severity (excludes SC1090, SC1091) |
| `test` | Runs `./tests/run_tests.sh` |
| `dry-run` | Runs `./install.sh --check --skip-packages --skip-secrets` |

## Branch Protection

`main` requires:
- PR (no direct push)
- All CI jobs pass
- Enforced for admins

## Branch Model

- `dev` — Commit here, CI runs on push
- `main` — Stable, receives PRs from `dev`, version tags (vX.Y.Z) applied here
- Update /README.md version badge to match new version tag
- Never push directly to `main`

## Local Validation

```bash
shellcheck -S warning -e SC1090 -e SC1091 install.sh lib/*.sh
./tests/run_tests.sh
./install.sh --check --skip-packages --skip-secrets
```

## Boundaries

- ✅ Add new CI jobs as needed
- ✅ Keep shellcheck exclusions minimal and documented
- 🚫 Never skip CI checks for PRs to main
- 🚫 Never disable branch protection
