{
  description = "Lintfra - ast-grep + clippy + custom lint rules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, lib, self', ... }:
        let
          astGrep = import ./nix/lib/ast-grep-rule.nix { inherit lib; };
          customRule = import ./nix/lib/custom-rule.nix { inherit lib; };

          # ast-grep rules from lint/rules/
          astRulesDir = ./lint/rules;
          astRuleFiles = builtins.filter (f: lib.hasSuffix ".nix" f) (
            builtins.attrNames (builtins.readDir astRulesDir)
          );
          astRules = map (f: {
            name = lib.removeSuffix ".nix" f;
            rule = import (astRulesDir + "/${f}") { inherit (astGrep) mkRule; };
          }) astRuleFiles;

          generatedAstRules = pkgs.runCommand "ast-grep-rules" { buildInputs = [ pkgs.yq-go ]; } ''
            mkdir -p $out
            ${lib.concatMapStringsSep "\n" (
              r: ''echo '${astGrep.toJson r.rule}' | yq -P > $out/${r.name}.yml''
            ) astRules}
          '';

          # custom rules from lint/custom/ - passed as JSON to lint-runner
          customRulesDir = ./lint/custom;
          customRuleFiles = builtins.filter (f: lib.hasSuffix ".nix" f) (
            builtins.attrNames (builtins.readDir customRulesDir)
          );
          customRules = map (f:
            import (customRulesDir + "/${f}") customRule
          ) customRuleFiles;

          customRulesJson = builtins.toJSON customRules;

          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        in
        {
          formatter = treefmtEval.config.build.wrapper;

          packages = {
            lint = pkgs.writeShellScriptBin "lint" ''
              export LINTFRA_RULES="${generatedAstRules}"
              export LINTFRA_CUSTOM_RULES='${customRulesJson}'
              if [[ -f ./nix/scripts/lint-runner.nu ]]; then
                exec ${pkgs.nushell}/bin/nu ./nix/scripts/lint-runner.nu "$@"
              else
                echo "Error: lint-runner.nu not found. Run from project root." >&2
                exit 1
              fi
            '';

            lint-rules = generatedAstRules;

            lint-rules-sync = pkgs.writeShellScriptBin "lint-rules-sync" ''
              set -e
              mkdir -p lint/ast-rules
              rm -f lint/ast-rules/*.yml
              cp ${generatedAstRules}/*.yml lint/ast-rules/
              echo "Synced ${toString (builtins.length astRules)} ast-grep rules"
            '';
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.ast-grep
              pkgs.nushell
              pkgs.yq-go
              self'.packages.lint
              self'.packages.lint-rules-sync
              self'.formatter
            ];

            shellHook = ''
              # Sync generated ast-grep rules
              mkdir -p lint/ast-rules
              cp ${generatedAstRules}/*.yml lint/ast-rules/ 2>/dev/null || true

              # Install pre-commit hook
              if [ -t 0 ] && [ -d .git ] && [ -f ./nix/scripts/pre-commit.nu ]; then
                cat > .git/hooks/pre-commit << 'EOF'
              #!/usr/bin/env bash
              exec nu ./nix/scripts/pre-commit.nu "$@"
              EOF
                chmod +x .git/hooks/pre-commit
              fi

              echo "lintfra devshell"
              echo "  lint            - run linter"
              echo "  lint-rules-sync - regenerate ast-grep yaml"
            '';
          };

          checks = {
            formatting = treefmtEval.config.build.check inputs.self;
          };
        };
    };
}
