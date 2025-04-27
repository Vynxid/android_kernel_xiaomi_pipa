# About this repo
This repo is based on [Lineage OS 21 xiaomi sm8250 kernel source](https://github.com/LineageOS/android_kernel_xiaomi_sm8250).

The main purpose of maintaining and building this kernel is to fix [this battery stuck at 1% problem](https://github.com/liyafe1997/Xiaomi-fix-battery-one-percent), and provide KernelSU integrated pre-built image(flashable anykernel3 zip). Also provides a more intuitive and easy-to-use build script and build guide that allow you to try to build by yourself.

The devices affected by the "1% battery bug" are: alioth, apollo, lmi, thyme, umi, pipa. Because they all use the PM8150, aka Qualcomm fuel gauge GEN4. For the other devices are not affected by that bug, you can use this kernel for KernelSU purpose, as a replacement of the orginal stock kernel.

# How to build
1. Prepair the basic build environment. 

    You have to have the basic common toolchains, such as `git`, `make`, `curl`, `bison`, `flex`, `zip`, etc, and some other packages.
    In Debian/Ubuntu, you can
    ```
    sudo add-apt-repository universe
    sudo apt update
    sudo apt install bc binutils-dev bison build-essential ca-certificates ccache clang cmake cpio curl file flex git libelf-dev libssl-dev lld make ninja-build python3-dev texinfo u-boot-tools xz-utils zlib1g-dev
    ```
    Notice: `ccache` is enabled in `build.sh` for speed up the compiling. `CCACHE_DIR` has been set as `$HOME/.cache/ccache_mikernel` in `build.sh`. If you don't like you can remove or modify it.

2. Download [ZYC-clang] compiler toolchain or any latest toolchain

    You have to have `aarch64-linux-gnu`, `arm-linux-gnueabi`, `clang`. [ZYC Clang](https://github.com/ZyCromerZ/Clang.git) is a good prebuilt clang cross compiler toolchain. Always use latest toolchain from releases, here is an example...

    ```
    mkdir tc
    cd tc
    wget https://github.com/ZyCromerZ/Clang/releases/download/21.0.0git-20250422-release/Clang-21.0.0git-20250422.tar.gz
    tar -xvzf Clang-21.0.0git-*
    cd ..
    ```
    
4. Build

    Build Kernel: 
    ```
    bash build.sh
    ```
