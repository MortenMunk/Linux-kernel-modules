# Linux-kernel-modules
Playing around with kernel modules

## How to run

### Get kernel
If you don't have the kernel folder, then run below from root:
```bash
get-kernel
```

The version can be changed in the flake.

### Configure kernel

```bash
cd kernel
kmake versatile_defconfig
```

### Build kernel and device tree

```bash
kmake -j${nproc}
kmake versatile-pb.dtb
```

### Compile modules

Enter the folder with your desired module (`hello-world` in below example), and compile it using `kmake`

```
cd ../modules/hello-world
kmake
```

### Run QEMU

Use the command from the flake to run QEMU

```bash
run-qemu
```

### Load modules inside QEMU

Replace `hello-world` for below with whatever module you want to load

```bash
cd /mnt/hello-world
insmod main.ko
```

And check the kernel logs
```bash
dmesg | tail
```

### Close QEMU

Emulator can be closed with `Ctrl + a` and then `x`
