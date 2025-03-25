{
  "self": "overlays/default.nix",
  "description": "This file defines package overlays for customizing or extending existing Nix packages.",
  "overlays": [
    {
      "name": "myOverlay",
      "overlay": self: super: {
        # Example of overriding a package
        myPackage = super.myPackage.override {
          # Custom attributes
        };
      }
    }
  ]
}