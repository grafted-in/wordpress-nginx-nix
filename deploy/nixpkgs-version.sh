#!/usr/bin/env bash

# Check out different Nixpkgs channels here:
#   * http://howoldis.herokuapp.com/
#   * https://nixos.org/channels/
#
# To upgrade:
#   1. Choose a channel and click on it.
#   2. Get the URL of the `nixexprs.tar.xz` file for the channel.
#   3. Run `nix-preftech-zip` (you may need to install it with `nix-env -i`)
#      on the URL to get the SHA-256 hash.
#   4. Paste both the URL and hash below:

export nixpkgs_channel="https://nixos.org/channels/nixpkgs-unstable"
export nixpkgs_snapshot="https://d3g5gsiof5omrk.cloudfront.net/nixpkgs/nixpkgs-17.03pre98765.6043569/nixexprs.tar.xz"

# See latest builds of NixOps for each platform:
#   http://hydra.nixos.org/jobset/nixops/master#tabs-jobs
if [ "$(uname)" == "Darwin" ]; then
  export nixops_version="/nix/store/1gy62jcxjc09n9gk0ns4qk3d9b9kcda7-nixops-1.5pre2121_fc43d9c"
else
  export nixops_version="/nix/store/d553achr2pvh6p8838a4shbhjpp5d6s6-nixops-1.5pre2121_fc43d9c"
fi

if [ ! -d "$nixops_version" ]; then
  nix-store -r "$nixops_version"
fi
