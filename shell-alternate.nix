{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

with nixpkgs.pkgs; with nixpkgs.pkgs.lib;

let

  inherit (nixpkgs) pkgs lib;

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};


  jrg-gitit-plugins = haskellPackages.callPackage ../jrg-gitit-plugins {};
  drv = haskellPackages.callPackage ./. { inherit jrg-gitit-plugins; };

  systemDepends = with pkgs; [ 
    curl
    wget
    graphviz
    plantuml
    ditaa
    jre
    diagrams-builder
    (texlive.combine {
      inherit (texlive) scheme-small inconsolata helvetic texinfo fancyvrb cm-super;
    })
    imagemagick 
    #imagemagickBig

    cabal-install
  ];

  
  removedPkgs = [
    jrg-gitit-plugins
    haskellPackages.gitit
  ];

  getPkgDepends = x: x.nativeBuildInputs ++ x.propagatedNativeBuildInputs;


  removedPkgsDepends = concatMap getPkgDepends removedPkgs;


  drvDependsMinusLibs = subtractLists removedPkgs (
                        getPkgDepends drv ++ removedPkgsDepends);


  combinedDepends = unique(drvDependsMinusLibs);

  isHaskellPkg = x: (x ? pname) && (x ? version) && (x ? env);
  isSystemPkg = x: !isHaskellPkg x;

  haskellBuildInputs = stdenv.lib.filter isHaskellPkg combinedDepends;
  systemBuildInputs = systemDepends ++ 
    stdenv.lib.filter isSystemPkg combinedDepends;

  ghcEnv = haskellPackages.ghcWithHoogle (p: haskellBuildInputs);

  isGhcjs = false;
  ghcCommand = if isGhcjs then "ghcjs" else "ghc";
  ghcCommandCaps = toUpper ghcCommand;

  # Could perform useful commands here.
  shellHook = ''

  '';

  env = stdenv.mkDerivation {
    name = "interactive-${drv.pname}-${drv.version}-environment";
    nativeBuildInputs = [ ghcEnv systemBuildInputs ];
    LANG = "en_US.UTF-8";
    LOCALE_ARCHIVE = optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
    shellHook = ''
      export NIX_${ghcCommandCaps}="${ghcEnv}/bin/${ghcCommand}"
      export NIX_${ghcCommandCaps}PKG="${ghcEnv}/bin/${ghcCommand}-pkg"
      export NIX_${ghcCommandCaps}_DOCDIR="${ghcEnv}/share/doc/ghc/html"
      export NIX_${ghcCommandCaps}_LIBDIR="${ghcEnv}/lib/${ghcEnv.name}"
      ${shellHook}
    '';
  };

in

  if pkgs.lib.inNixShell then env else drv
