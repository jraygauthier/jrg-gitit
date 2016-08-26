{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs lib;

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};


  jrg-gitit-plugins = haskellPackages.callPackage ../jrg-gitit-plugins {};
  drv = haskellPackages.callPackage ./. { inherit jrg-gitit-plugins; };
  drvEnv = pkgs.haskell.lib.overrideCabal drv (attrs: {
    executableSystemDepends = with pkgs; [ 
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
    ];
  });

in

  if pkgs.lib.inNixShell then drvEnv.env else drv
