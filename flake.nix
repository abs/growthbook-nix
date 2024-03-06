{
  description = "Growthbook dev environment";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      # Add dependencies that are only needed for development
      devShells = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
          nodejs = pkgs.nodejs_18;
          yarn = pkgs.yarn.override {
            inherit nodejs;
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              yarn nodejs
              python3 poetry
              go gopls gotools go-tools
              docker
            ];
          };
        });

    };
}
