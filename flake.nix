{
  inputs.kernelFlake.url = "github:jordanisaacs/kernel-module-flake";

  outputs = {
    self,
    nixpkgs,
    kernelFlake,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    kernelLib = kernelFlake.lib.builders {inherit pkgs;};
    buildLib = kernelLib;
    kernel = pkgs.linux_latest;

    buildCModule = buildLib.buildCModule {inherit kernel;};

    modules = [exampleModule];

    initramfs = buildLib.buildInitramfs {
      inherit kernel modules;
    };

    exampleModule = buildCModule {
      name = "hello-world";
      src = ./.;
    };

    runQemu = buildLib.buildQemuCmd {inherit kernel initramfs;};
    runGdb = buildLib.buildGdbCmd {inherit kernel modules;};
  in {
    packages.${system} = {
      default = exampleModule;
      runvm = runQemu;
      rungdb = runGdb;
    };

    apps.${system} = {
      default = {
        type = "app";
        program = "${runQemu}/bin/run-vm";
      };
      debug = {
        type = "app";
        program = "${runGdb}/bin/run-gdb";
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [exampleModule];
      nativeBuildInputs = with pkgs; [
        gnumake
        pahole
        bear
      ];
      shellHook = ''
        export KDIR="${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      '';
    };
  };
}
