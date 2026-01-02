{
  pkgs,
  self,
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
  formatting = formatterEval.config.build.check self;

  ast-grep-scan = pkgs.runCommand "ast-grep-scan" { } ''
    cd ${self}
    ${pkgs.ast-grep}/bin/ast-grep scan
    touch $out
  '';
}
