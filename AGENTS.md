# lintfra

Shared linting infrastructure injected into projects via imp.gits.

## Integration

Lintfra files are synced into target projects under `nix/outputs/perSystem/` and `lint/`.

imp.lib's tree automatically merges `.d/` directories:
- `packages.d/10-lint.nix` is merged into `self'.packages` (provides `self'.packages.lint`)
- `shell-packages.d/10-lintfra.nix` provides devshell packages (used via `imp.fragmentsWith`)

No manual configuration needed in target projects - just sync the files and it works.

## Files Provided

- `packages.d/10-lint.nix` - lint package (merged into `self'.packages`)
- `shell-packages.d/10-lintfra.nix` - devshell packages fragment (list)
- `shellHook.d/10-lintfra.sh` - pre-commit hook setup
- `nix/scripts/lint-runner` - unified ast-grep + custom rules runner
- `nix/scripts/pre-commit` - git hook
- `lint/` - ast-grep rules and custom rule definitions

## Directory Conventions

- `packages.d/` - attrset fragments merged into `self'.packages`
- `shell-packages.d/` - list fragments for devshell packages
- `shellHook.d/` - shell script fragments concatenated into shellHook
