{
  description = "imp.lint - ast-grep + clippy + custom lint rules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    imp.url = "github:imp-nix/imp.lib";
    imp.inputs.nixpkgs.follows = "nixpkgs";
    imp.inputs.flake-parts.follows = "flake-parts";

    imp-fmt.url = "github:imp-nix/imp.fmt";
    imp-fmt.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    imp-fmt.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      imp,
      imp-fmt,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ imp.flakeModules.default ];

      imp = {
        src = ./outputs;
        args = {
          inherit self treefmt-nix imp-fmt;
        };
      };
    };
}
