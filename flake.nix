{
  description = "Buildboot development environment and native tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.alejandra
      );

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          imx-cst = pkgs.callPackage ./nix/packages/imx-cst { };
          imx-signer = pkgs.callPackage ./nix/packages/imx-signer { };
          arm-none-eabi-toolchain = pkgs.callPackage ./nix/packages/arm-none-eabi-toolchain {
            stdenvCcLib = pkgs.stdenv.cc.cc.lib;
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          imx-cst = self.packages.${system}.imx-cst;
          imx-signer = self.packages.${system}.imx-signer;
          arm-none-eabi-toolchain = self.packages.${system}.arm-none-eabi-toolchain;
        in
        {
          default = import ./nix/shells/buildboot.nix {
            inherit pkgs imx-cst imx-signer arm-none-eabi-toolchain;
          };
        }
      );
    };
}
