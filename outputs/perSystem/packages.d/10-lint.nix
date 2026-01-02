/**
  Lint package for self'.packages.
  Returns attrset to be merged into packages output.
*/
{ pkgs, ... }:
{
  lint = pkgs.writeShellScriptBin "lint" ''
    if [[ -f ./nix/scripts/lint-runner.nu ]]; then
      exec ${pkgs.nushell}/bin/nu ./nix/scripts/lint-runner.nu "$@"
    elif [[ -x ./nix/scripts/lint-runner ]]; then
      exec ./nix/scripts/lint-runner "$@"
    else
      echo "Error: lint-runner not found. Run from project root." >&2
      exit 1
    fi
  '';
}
