{ mkDerivation, base, bytestring, directory, gitit, hslogger
, jrg-gitit-plugins, mtl, network, network-uri, stdenv, utf8-string
}:
mkDerivation {
  pname = "jrg-gitit";
  version = "0.0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring directory gitit hslogger jrg-gitit-plugins mtl
    network network-uri utf8-string
  ];
  license = "GPL";
}
