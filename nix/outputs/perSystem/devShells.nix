# Lintfra standalone devshell
# For repos that only use lintfra directly
{ pkgs, self', ... }:
{
  default = pkgs.mkShell {
    inputsFrom = [ self'.devShells.lintfra ];
    packages = [ self'.formatter ];

    shellHook = ''
      ${self'.devShells.lintfra.shellHook}
      echo ""
      echo "lintfra devshell"
    '';
  };
}
