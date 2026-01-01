# Lintfra devshell using fragment composition
{ pkgs, self', imp, ... }:
let
  shellHookFragments = imp.fragments ./shellHook.d;
  # shell-packages.d/ contains list fragments for devshell packages
  # (separate from packages.d/ which contains attrset fragments for self'.packages)
  shellPackageFragments = imp.fragmentsWith { inherit pkgs self'; } ./shell-packages.d;
in
{
  default = pkgs.mkShell {
    packages = shellPackageFragments.asList ++ [ self'.formatter ];
    shellHook = ''
      ${shellHookFragments.asString}
      echo ""
      echo "lintfra devshell"
    '';
  };
}
