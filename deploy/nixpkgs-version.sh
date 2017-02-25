#!/usr/bin/env bash

# Check out different Nixpkgs channels here:
#   * http://howoldis.herokuapp.com/
#   * https://nixos.org/channels/
#
# To upgrade:
#   1. Choose a channel and click on it.
#   2. Get the URL of the `nixexprs.tar.xz` file for the channel.
#   4. Paste the URL below for `nixpkgs_snapshot`.

export nixpkgs_channel="https://nixos.org/channels/nixpkgs-unstable"  # For reference only.
export nixpkgs_snapshot="https://d3g5gsiof5omrk.cloudfront.net/nixpkgs/nixpkgs-17.03pre101896.4a524cf/nixexprs.tar.xz"
export nixops_version="nixops"