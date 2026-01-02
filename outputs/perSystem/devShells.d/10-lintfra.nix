/**
  Composable lintfra shell configuration.
  Provides packages and shellHook for lint tooling.

  Usage in consuming repo's devShells.nix:

  ```nix
  {
    default = pkgs.mkShell {
      inputsFrom = [ self'.devShells.lintfra ];
      packages = [ ... ];  # your packages
    };
  }
  ```
*/
{ pkgs, self', ... }:
{
  lintfra = pkgs.mkShell {
    packages = [
      pkgs.ast-grep
      pkgs.nushell
      self'.packages.lint
    ];

    shellHook = ''
      # Install pre-commit hook
      if [ -t 0 ] && [ -d .git ]; then
        if [ -f ./nix/scripts/pre-commit.nu ]; then
          cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
exec nu ./nix/scripts/pre-commit.nu "$@"
EOF
          chmod +x .git/hooks/pre-commit
        elif [ -x ./nix/scripts/pre-commit ]; then
          cp ./nix/scripts/pre-commit .git/hooks/pre-commit
          chmod +x .git/hooks/pre-commit
        fi
      fi

      echo "Lint: lint (ast-grep + clippy + custom rules)"
    '';
  };
}
