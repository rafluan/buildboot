{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "variscite-imx-signer";
  version = "3.0-var01-25f0c94";

  src = fetchFromGitHub {
    owner = "varigit";
    repo = "nxp-cst-signer";
    rev = "25f0c9482af267710294af2fc996e3ba4dbf439b";
    hash = "sha256-KO7bKM1+bV2n0KUX+zfNWq5u/UrozvpJ3FT/U/gA4Oo=";
  };

  buildPhase = ''
    runHook preBuild
    make -C src CFLAGS="-O2 -Wall"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 src/imx_signer "$out/bin/imx_signer"
    runHook postInstall
  '';

  meta = {
    description = "Variscite's HAB/AHAB image signer wrapper";
    homepage = "https://github.com/varigit/nxp-cst-signer";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
