# lintfra

Shared linting infrastructure injected into projects via imp.gitbits.

## Integration

Lintfra files are synced into target projects under `nix/outputs/perSystem/` and `lint/`. The `packages.d/10-lintfra.nix` fragment adds lint tools to devshells; it references `self'.packages.lint`.

**Requirement:** The target project's `packages.nix` must define `lint`. Either inline it directly or ensure no `packages/default.nix` exists (which would shadow sibling files).

## Files Provided

- `packages.d/10-lintfra.nix` - devshell packages fragment
- `shellHook.d/10-lintfra.sh` - pre-commit hook setup
- `packages/lint.nix` - lint command wrapper
- `nix/scripts/lint-runner` - unified ast-grep + custom rules runner
- `nix/scripts/pre-commit` - git hook
- `lint/` - ast-grep rules and custom rule definitions
