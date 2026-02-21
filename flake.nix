{
  description = "ARM Kernel Module Dev Lab - FHS Compatible";

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

    fhs = pkgs.buildFHSEnv {
      name = "kernel-build-env";
      targetPkgs = pkgs:
        with pkgs; [
          gnumake
          gcc
          binutils
          ncurses
          flex
          bison
          bc
          elfutils
          openssl
          perl
          util-linux
          pkg-config
          gnum4
          gawk
        ];
    };

    get-kernel = pkgs.writeScriptBin "get-kernel" ''
      #!/usr/bin/env bash
      echo "Downloading Kernel v${kernel-version}..."
      curl -L https://cdn.kernel.org/pub/linux/kernel/v${kernel-prefix}.x/linux-${kernel-version}.tar.xz | tar -xJ
      mv linux-${kernel-version} kernel
      echo "Done! Run: cd kernel && kmake versatile_defconfig && kmake -j$(nproc)"
    '';

    kmake = pkgs.writeScriptBin "kmake" ''
      #!/usr/bin/env bash
      ${fhs}/bin/kernel-build-env -c "make ARCH=arm CROSS_COMPILE=armv7l-unknown-linux-gnueabihf- $*"
    '';

    run-qemu = pkgs.writeScriptBin "run-qemu" ''
      #!/usr/bin/env bash
      qemu-system-arm -M versatilepb \
        -kernel $KDIR/arch/arm/boot/zImage \
        -dtb $KDIR/arch/arm/boot/dts/versatile-pb.dtb \
        -initrd rootfs.cpio.gz \
        -append "console=ttyAMA0 root=/dev/ram0" \
        -serial stdio -display none \
        --virtfs local,path=$PWD/exercises,mount_tag=hostshare,security_model=none,id=hostshare
    '';
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        gnutar
        xz
        curl
        qemu
        gdb
        ncurses

        get-kernel
        kmake
        run-qemu

        armPkgs.stdenv.cc
      ];

      shellHook = ''
        export ARCH=arm
        export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
        export KDIR=$PWD/kernel

        echo "Commands: get-kernel, kmake, run-qemu"

        if [ ! -d "$KDIR" ]; then
          echo "⚠️  Kernel source not detected in ./kernel. Run 'get-kernel' to start."
        fi
      '';
    };
  };
}
