#!/bin/bash

# Ensure the script exits on error
set -e

TOOLCHAIN_PATH=$HOME/tc/bin
GIT_COMMIT_ID=$(git rev-parse --short=8 HEAD)

if [ ! -d $TOOLCHAIN_PATH ]; then
    echo "TOOLCHAIN_PATH [$TOOLCHAIN_PATH] does not exist."
    echo "Please ensure the toolchain is there, or change TOOLCHAIN_PATH in the script to your toolchain path."
    exit 1
fi

echo "TOOLCHAIN_PATH: [$TOOLCHAIN_PATH]"
export PATH="$TOOLCHAIN_PATH:$PATH"

if ! command -v aarch64-linux-gnu-ld >/dev/null 2>&1; then
    echo "[aarch64-linux-gnu-ld] does not exist, please check your environment."
    exit 1
fi

if ! command -v arm-linux-gnueabi-ld >/dev/null 2>&1; then
    echo "[arm-linux-gnueabi-ld] does not exist, please check your environment."
    exit 1
fi

if ! command -v clang >/dev/null 2>&1; then
    echo "[clang] does not exist, please check your environment."
    exit 1
fi

# Enable ccache for speed up compiling
export CCACHE_DIR="$HOME/.cache/ccache_mikernel"
export CC="ccache gcc"
export CXX="ccache g++"
export PATH="/usr/lib/ccache:$PATH"
echo "CCACHE_DIR: [$CCACHE_DIR]"

MAKE_ARGS="ARCH=arm64 O=out CC=clang LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip"

# Check clang is existing.
echo "[clang --version]:"
clang --version

# Export variables
export KBUILD_BUILD_USER="aryan"
export KBUILD_BUILD_HOST="curiousnom"
export KBUILD_LAST_COMMIT=${GIT_COMMIT_ID}
export KBUILD_COMPILER_STRING="Google AOSP Clang 20.0.0 +pgo +bolt +lto +mlgo"
export KBUILD_LINKER_STRING="LLD 20.0.0"

echo "Cleaning..."
rm -rf out/
rm -rf error.log

echo "Cloning AnyKernel3 for packing kernel..."
if [ -d "anykernel/.git" ]; then
    echo "AnyKernel3 already cloned. Skipping."
else
    rm -rf anykernel  # optional: ensure clean state
    git clone https://github.com/CuriousNom/AnyKernel3 -b pipa --single-branch --depth=1 anykernel
fi

echo "Applying patch..."
git apply dtsi.patch

    # ------------- Building for MIUI/HOS -------------
    echo "Clearing [out/] and building for MIUI/HOS....."

    make $MAKE_ARGS pipa_defconfig miui.config

    make $MAKE_ARGS -j$(nproc --all) 2> >(tee -a error.log >&2)

    if [ -f "out/arch/arm64/boot/Image" ]; then
        echo "The file [out/arch/arm64/boot/Image] exists. MIUI Build successfully."
    else
        echo "The file [out/arch/arm64/boot/Image] does not exist. Seems MIUI build failed."
        exit 1
    fi

echo "Restoring patch..."
git apply -R dtsi.patch

    rm -rf anykernel/kernels/
    mkdir -p anykernel/kernels/
    cp out/arch/arm64/boot/Image.gz anykernel/kernels/
    cp out/arch/arm64/boot/dtb anykernel/kernels/

    cd anykernel
    ZIP_FILENAME=Kernel_BloodReaper_MIUI_pipa_$(date +'%Y%m%d_%H%M%S')_anykernel3_${GIT_COMMIT_ID}.zip
    zip -r9 $ZIP_FILENAME ./* -x .git .gitignore out/ ./*.zip
    mv $ZIP_FILENAME ../
    cd ..

    echo "Build for MIUI/HOS finished."

echo "Done. The flashable zip is: [./$ZIP_FILENAME]"
