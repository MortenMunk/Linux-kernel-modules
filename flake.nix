{
  description = "ARM Kernel Module Dev Lab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {inherit system;};

    armPkgs = import nixpkgs {
      inherit system;
      crossSystem = {
        config = "armv7l-unknown-linux-gnueabihf";
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        qemu
        ncurses
        flex
        bison
        bc
        elfutils
        openssl
        cpio
        gnumake
        perl
        pahole

        armPkgs.stdenv.cc
      ];

      shellHook = ''
        export ARCH=arm
        export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
        echo "ARM Kernel Module Lab Ready ✔"
        alias kmake='make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE'
      '';
    };
  };
}
