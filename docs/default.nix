{ pkgs, haumea, nmd, lib }:

{
  docs = pkgs.callPackage ./mdbook {
    inherit haumea nmd;
  };
}
