{
  pkgs,
  lib,
  self,
  ...
}:
let
  astGrep = import "${self}/nix/lib/ast-grep-rule.nix" { inherit lib; };
  rulesDir = "${self}/lint/rules";

  # Load all .nix files from lint/rules/
  ruleFiles = builtins.filter (f: lib.hasSuffix ".nix" f) (
    builtins.attrNames (builtins.readDir rulesDir)
  );

  # Import each rule file
  rules = map (f: {
    name = lib.removeSuffix ".nix" f;
    rule = import (rulesDir + "/${f}") { inherit (astGrep) mkRule; };
  }) ruleFiles;

  # Generate YAML files using yq to convert JSON to YAML
  generatedRules = pkgs.runCommand "ast-grep-rules" { buildInputs = [ pkgs.yq-go ]; } ''
    mkdir -p $out
    ${lib.concatMapStringsSep "\n" (
      r: ''echo '${astGrep.toJson r.rule}' | yq -P > $out/${r.name}.yml''
    ) rules}
  '';
in
{
  lint-rules = generatedRules;

  lint-rules-sync = pkgs.writeShellScriptBin "lint-rules-sync" ''
    set -e
    dest="''${1:-lint/ast-rules}"
    mkdir -p "$dest"
    rm -f "$dest"/*.yml
    cp ${generatedRules}/*.yml "$dest/"
    echo "Synced ${toString (builtins.length rules)} rules to $dest"
  '';
}
