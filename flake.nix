{
  inputs.stable.url = "github:nixos/nixpkgs/release-22.05";
  inputs.latest.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = {
    self,
    stable,
    latest,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      stablePkgs = import stable {
        inherit system;
        config.allowUnfree = true;
      };
      latestPkgs = import latest {
        inherit system;
        config.allowUnfree = true;
      };
      # some packages don't support aarch64-darwin (how the Mac M1 chip is
      # identified) but those systems support x86_64-darwin via rosetta
      stablePkgsWithOnlyX86DarwinSupport = import stable {
        system =
          if system == "aarch64-darwin"
          then "x86_64-darwin"
          else system;
        config.allowUnfree = true;
      };
      latestPkgsWithOnlyX86DarwinSupport = import latest {
        system =
          if system == "aarch64-darwin"
          then "x86_64-darwin"
          else system;
        config.allowUnfree = true;
      };
    in rec {
      runner-deps = with stablePkgs;
        [
          coreutils
          clojure
          git
          gnutar
          gzip
          which
        ]
        ++ (with latestPkgs; let
          tailwindcssWithPlugins = nodePackages.tailwindcss.overrideAttrs (oldAttrs: {
            plugins = [
              nodePackages."@tailwindcss/typography"
            ];
          });
        in [
          nodejs
          tailwindcssWithPlugins
        ])
        ++ (with latestPkgsWithOnlyX86DarwinSupport; [
          babashka
        ]);
      packages = rec {
        default = shell;
        shell = stablePkgs.writeTextFile rec {
          name = "garden-env";
          executable = true;
          destination = "/bin/${name}";
          text = ''
            #!${stablePkgs.runtimeShell}
            PATH="${stablePkgs.lib.makeBinPath runner-deps}" $SHELL
          '';
        };
      };
      apps.default = {
        type = "app";
        program = "${packages.shell}/bin/garden-env";
      };
    });
}
