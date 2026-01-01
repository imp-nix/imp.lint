/**
  Lintfra devshell.
  Uses inputsFrom to compose with the lintfra shell from devShells.d/.
*/
{ pkgs, self', ... }:
{
  default = pkgs.mkShell {
    inputsFrom = [ self'.devShells.lintfra ];
    packages = [ self'.formatter ];
    shellHook = ''
      echo ""
      echo "lintfra devshell"
    '';
  };
}
