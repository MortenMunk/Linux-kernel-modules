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
kmake defconfig
```

### Build kernel and device tree

```bash
kmake -j${nproc}
```

If you get OOM error, you can use something like `-j4` for a 8bg or 16gb RAM system.

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
cd /mnt/modules/hello-world
insmod main.ko
```

And check the kernel logs
```bash
dmesg | tail
```

### Close QEMU

Emulator can be closed with `Ctrl + a` and then `x`
