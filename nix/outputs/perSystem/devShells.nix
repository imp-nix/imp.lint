{
  __functor =
    _:
    {
      pkgs,
      rootSrc,
      self',
      ...
    }:
    {
      default = pkgs.mkShell {
        packages = [
          pkgs.ast-grep
          pkgs.yq-go
          pkgs.jq
          self'.packages.lint
          self'.formatter
        ];

        shellHook = ''
          if [ -t 0 ]; then
            # Install pre-commit hook
            if [ -d .git ]; then
              cp ${rootSrc}/nix/scripts/pre-commit .git/hooks/pre-commit
              chmod +x .git/hooks/pre-commit
            fi
          fi

          echo "lintfra devshell"
          echo ""
          echo "Commands:"
          echo "  lint        - Run unified lint (ast-grep + custom rules)"
          echo "  lint --json - Output lint results as JSON stream"
        '';
      };
    };
}
