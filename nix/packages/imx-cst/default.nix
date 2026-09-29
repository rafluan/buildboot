{ lib
, stdenv
, fetchurl
, gnumake
, byacc
, flex
, openssl
}:

stdenv.mkDerivation rec {
  pname = "imx-cst";
  version = "3.4.1";

  src = fetchurl {
    url = "https://deb.debian.org/debian/pool/main/i/imx-code-signing-tool/imx-code-signing-tool_${version}+dfsg.orig.tar.xz";
    hash = "sha256-NCwMAoZYpKhZ/nBXi1jDsH4XvuDH46E9Bj1HkegsLe4=";
  };

  sourceRoot = "imx-code-signing-tool-${version}+dfsg";

  patches = [ ./0001-fix-missing-makefile-rule-dependency.patch ];

  nativeBuildInputs = [ gnumake byacc flex ];
  buildInputs = [ openssl ];

  buildPhase = ''
    runHook preBuild

    make -C code/obj.linux64 OSTYPE=linux64 ENCRYPTION=yes \
      "COPTIONS=$NIX_CFLAGS_COMPILE" \
      CC="$CC" LD="$CC" AR="$AR" OBJCOPY="$OBJCOPY"
    make -C add-ons/hab_csf_parser \
      "COPTS=$NIX_CFLAGS_COMPILE" \
      CC="$CC" LD="$CC" AR="$AR" OBJCOPY="$OBJCOPY"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 code/obj.linux64/cst "$out/bin/cst"
    install -m755 code/obj.linux64/srktool "$out/bin/srktool"
    install -m755 add-ons/hab_csf_parser/csf_parser "$out/bin/csf_parser"
    runHook postInstall
  '';

  strictDeps = true;

  meta = {
    description = "NXP i.MX Code Signing Tool for HABv4 and AHAB image signing";
    homepage = "https://github.com/nxp-imx-support/imx-code-signing-tool";
    license = with lib.licenses; [ bsd3 asl20 ];
    platforms = [ "x86_64-linux" ];
  };
}
