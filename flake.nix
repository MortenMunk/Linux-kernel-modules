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
      crossSystem = {config = "armv7l-unknown-linux-gnueabihf";};
    };
    kernel-prefix = "5";
    kernel-version = "${kernel-prefix}.10.1";

    get-kernel = pkgs.writeScriptBin "get-kernel" ''
      #!/usr/bin/env bash
      echo "Downloading Kernel v${kernel-version}..."
      curl -L https://cdn.kernel.org/pub/linux/kernel/v${kernel-prefix}.x/linux-${kernel-version}.tar.xz | tar -xJ
      mv linux-${kernel-version} kernel
      echo "Done! Run: cd kernel && kmake versatile_defconfig && kmake -j$(nproc)"
    '';

    kmake = pkgs.writeScriptBin "kmake" ''
      #!/usr/bin/env bash
      make ARCH=arm CROSS_COMPILE=armv7l-unknown-linux-gnueabihf- "$@"
    '';

    run-qemu = pkgs.writeScriptBin "run-qemu" ''
      #!/usr/bin/env bash
      qemu-system-arm -M versatilepb \
        -kernel ./kernel/arch/arm/boot/zImage \
        -dtb ./kernel/arch/arm/boot/dts/versatile-pb.dtb \
        -initrd rootfs.cpio.gz \
        -append "console=ttyAMA0 root=/dev/ram0" \
        -serial stdio -display none \
        --virtfs local,path=$PWD/exercises,mount_tag=hostshare,security_model=none,id=hostshare
    '';
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        gnumake
        gnutar
        flex
        bison
        bc
        elfutils
        openssl
        cpio
        perl
        pahole
        curl
        xz
        qemu
        ncurses
        gdb
        armPkgs.stdenv.cc

        get-kernel
        kmake
        run-qemu
      ];

      shellHook = ''
        export ARCH=arm
        export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
        export KDIR=$PWD/kernel
        echo "Scripts available: get-kernel, kmake, run-qemu"
      '';
    };
  };
}
