#!/usr/bin/env bash
export nixpkgs_channel="https://nixos.org/channels/nixpkgs-unstable"
export nixpkgs_snapshot="https://d3g5gsiof5omrk.cloudfront.net/nixpkgs/nixpkgs-17.03pre97534.5ed1aee/nixexprs.tar.xz"

if [ "$(uname)" == "Darwin" ]; then
  export nixops_version="/nix/store/8kgw7k7z8rs2fp12253zr7f5sb4v311g-nixops-1.5pre2118_2d8b282"
else
  export nixops_version="/nix/store/h2dbmlnpnh7c7k0izmglxy270gs9nmwn-nixops-1.5pre2118_2d8b282"
fi

if [ ! -d "$nixops_version" ]; then
  nix-store -r "$nixops_version"
fi
