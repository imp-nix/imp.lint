{
  pkgs,
  self',
  treefmt-nix,
  imp-fmt,
  ...
}:
let
  formatterEval = imp-fmt.lib.makeEval {
    inherit pkgs treefmt-nix;
    excludes = [
      "target/*"
      "**/target/*"
    ];
    rust.enable = true;
  };
in
{
  default = pkgs.mkShell {
    inputsFrom = [
      self'.devShells.imp-lint
      formatterEval.config.build.devShell
    ];
    shellHook = ''
      echo ""
      echo "imp.lint devshell"
    '';
  };
}
