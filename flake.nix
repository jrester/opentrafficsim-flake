{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.maven.buildMavenPackage rec {
          version = "1.7.5";
          pname = "opentrafficsim";
          name = "${pname}-${version}";
          src = pkgs.fetchFromGitHub {
            owner = "averbraeck";
            repo = "opentrafficsim";
            rev = "v${version}";
            sha256 = "sha256-j4nMuQzM6QYLsEofHVIzCoQYhT0kJifn3eFh79ytwgo=";
          };
          mvnHash = "sha256-NNhWe2LIm5plzBEiqMxf9C6t4PAZDfnS3RafwKFetQo=";

          patches = [ ./patches/0001-activate-fat-jar-plugin-required-for-cr-ots-coupling.patch ];

          installPhase = ''
            for otsModulePath in ots-*; do
              # remove all path delimters (/) and suffixes
              otsModuleName="''${otsModulePath##*/}"
              otsModuleJarName=$otsModuleName-${version}.jar
              otsModuleJarSourcePath=$otsModulePath/target/$otsModuleJarName
              otsModuleJarTargetPath=$out/$otsModuleName/target/$otsModuleJarName
              echo "Copying $otsModuleJarSourcePath to $otsModuleJarTargetPath"
              mkdir -p $out/$otsModuleName/target
              cp $otsModuleJarSourcePath $otsModuleJarTargetPath
            done
          '';
        };
      }
    );
}
