{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, libxcrypt
, xz
, zlib
, zstd
, ncurses
, stdenvCcLib
}:

stdenv.mkDerivation rec {
  pname = "arm-none-eabi-toolchain";
  version = "15.2.rel1";

  src = fetchurl {
    url = "https://developer.arm.com/-/media/Files/downloads/gnu/${version}/binrel/arm-gnu-toolchain-${version}-x86_64-arm-none-eabi.tar.xz";
    hash = "sha256-WXiTKCrIxqsaQHOXfyNimQGEWZZDtMXuNIcKghV4OhY=";
  };

  sourceRoot = "arm-gnu-toolchain-${version}-x86_64-arm-none-eabi";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenvCcLib libxcrypt xz zlib zstd ncurses ];

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    toolchain="$out/libexec/${pname}-${version}"
    mkdir -p "$toolchain" "$out/bin"
    cp -a . "$toolchain/"

    # This optional debugger frontend requires the bundle's Python 3.8 ABI.
    rm -f "$toolchain/bin/arm-none-eabi-gdb-py"

    for tool in "$toolchain"/bin/*; do
      ln -s "$tool" "$out/bin/$(basename "$tool")"
    done

    runHook postInstall
  '';

  meta = {
    description = "Arm GNU bare-metal toolchain for Cortex-M, matching the NXP Yocto recipe";
    homepage = "https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads";
    # The matching Yocto recipe declares GPL-3.0-with-GCC-exception & GPL-3.0-only.
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
