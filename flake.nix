{
  description = "pianoplayer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem ([ "aarch64-linux" "i686-linux" "x86_64-linux" ])
    (system:
      let
        pkgs = import nixpkgs { inherit system; };
        music21 = with pkgs.python3Packages;
          buildPythonPackage rec {
            pname = "music21";
            version = "7.1.0";
            src = fetchPypi {
              inherit pname version;
              sha256 = "BjFcjyo0tSARhCqBwImCbVU3TsCfNY2rxz2lilGLYp8=";
            };
            propagatedBuildInputs = [
              chardet
              joblib
              jsonpickle
              matplotlib
              more-itertools
              numpy
              webcolors
            ];
            doCheck = false;
          };
        vedo = with pkgs.python3Packages;
          buildPythonPackage rec {
            pname = "vedo";
            version = "2021.0.6";
            src = fetchPypi {
              inherit pname version;
              sha256 = "XR9+lrx4tFKt1mjLZ41/1FcB9IFdD56+3eH7VhhGoCM=";
            };
            # https://github.com/NixOS/nixpkgs/issues/84774
            postPatch = ''
              substituteInPlace setup.py --replace "\"vtk\", " ""
              substituteInPlace ${pname}.egg-info/requires.txt --replace "vtk" ""
            '';
            propagatedBuildInputs = [ numpy vtk_9 deprecated ];
            doCheck = false;
          };
        pretty_midi = with pkgs.python3Packages;
          buildPythonPackage rec {
            pname = "pretty_midi";
            version = "0.2.9";
            src = fetchPypi {
              inherit pname version;
              sha256 = "9qJJy4Q0QeHLeMTAoSkJSNb1bfdIb3l04g1cgEhtyZ4=";
            };
            propagatedBuildInputs = [ numpy mido six ];
          };
        pianoplayer = with pkgs.python3Packages;
          buildPythonPackage rec {
            pname = "pianoplayer";
            version = "2.2.0";
            src = fetchPypi {
              inherit pname version;
              sha256 = "lwGhC6Lus4LlGZm37CMXDU5kUKNfo4kDGGOk2POiHmY=";
            };
            propagatedBuildInputs = [ music21 vedo pretty_midi ];
          };
      in {
        defaultPackage = pianoplayer;
        defaultApp = {
          type = "app";
          program = "${pianoplayer}/bin/pianoplayer";
        };
      });
}
