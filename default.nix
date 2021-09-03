{ pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem }:

let inherit (pkgs) lib;
    releases = builtins.fromJSON (lib.strings.fileContents ./sources.json);

in lib.attrsets.mapAttrs (k: v: 
  lib.attrsets.mapAttrs (k: v:
    (pkgs.stdenv.mkDerivation {
      pname = "zig";
      inherit (v.${system}) version;
      src = pkgs.fetchurl {
        inherit (v.${system}) url sha256;
      };
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out/{doc,bin,lib}
        [ -d docs ] && cp -r docs/* $out/doc
        [ -d doc ] && cp -r doc/* $out/doc
        cp -r lib/* $out/lib
        cp zig $out/bin/zig
      '';
    }))
    v
  releases