{ pkgs, imx-cst, imx-signer, arm-none-eabi-toolchain }:

let
  arm64 = pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc;
  arm32 = pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc;
in
pkgs.mkShell {
  packages = with pkgs; [
    # Native tools and ARM cross-compilers
    gcc
    binutils
    gnumake
    arm64
    arm32
    arm-none-eabi-toolchain

    # U-Boot, ATF, and i.MX image packaging requirements
    bc
    bison
    flex
    dtc
    ncurses
    cpio
    lz4
    openssl
    zlib.dev
    perl
    rsync
    elfutils
    util-linux.dev
    gnutls.dev
    pkgsCross.aarch64-multiplatform.util-linux
    pkgsCross.aarch64-multiplatform.gnutls

    # Source and firmware management
    git
    wget
    file
    unzip
    which

    # Build utilities used by supported source trees
    gettext
    pkg-config
    libtool
    automake
    autoconf
    meson
    ninja

    # Python utilities used by U-Boot and Buildboot
    (python3.withPackages (pythonPackages: with pythonPackages; [
      jsonschema
      pyelftools
      pyyaml
    ]))

    imx-cst
    imx-signer
  ];

  CROSS_COMPILE = arm64.targetPrefix;
  CROSS_COMPILE_ARM32 = arm32.targetPrefix;
  ARM_NONE_EABI_PREFIX = "${arm-none-eabi-toolchain}/bin/arm-none-eabi-";
  SIG_TOOL_PATH = "${imx-cst}/bin";

  shellHook = ''
    export ARCH=arm64
    export LDFLAGS="$LDFLAGS -Wl,--no-warn-rwx-segments"
    echo "Buildboot environment ready (AArch64, ARM32, ARM bare-metal, CST)."
  '';
}
