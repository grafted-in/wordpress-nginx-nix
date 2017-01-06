{ fetchzip, runCommand, unzip, ... }: {
  # Builds a package from a zip archive.
  # The archive must have exactly one, top-level directory which will stripped.
  # Example: zipArchive "my-package-name" ./my-package.zip
  zipArchive = name: path: runCommand name { buildInputs = [ unzip ]; } ''
    unzip "${path}" -d "$TEMPDIR"
    top_dir=$(find "$TEMPDIR" -type d -mindepth 1 -maxdepth 1)
    if [ "$(echo "$top_dir" | wc -l)" -ne 1 ]; then
      echo Archive must have exactly one top-level directory.
      exit 1
    fi

    mv "$top_dir" "$out"
  '';

  # Builds a package from a folder.
  # Example: folder "my-package-name" ./my-package
  folder = name: path: runCommand name {} ''
    ln -s "${path}" "$out"
  '';

  # Builds a package from a registered WordPress plugin.
  # Example: getPlugin "akismet" "3.2" "0ri9a0lbr269r3crmsa6hn4v4nd4dyblrb0ffvkmig2pvvx25hyn"
  # To determine the name, version, and SHA256 hash of a plugin, find it on
  # https://wordpress.org/plugins and look at the URL of the "Download" button. Most URLs will tell
  # you the name and version. To determine the hash, install `nix-prefetch-zip`
  # (via `nix-env -i nix-prefetch-zip`) and run it on the plugin URL:
  #   `nix-prefetch-zip <URL>`.
  getPlugin = name: version: sha256: fetchzip {
    inherit name sha256;
    url = "https://downloads.wordpress.org/plugin/${name}.${version}.zip";
  };

  # Builds a package from a registered WordPress theme.
  # Example: getTheme "twentyseventeen" "1.0" "01779xz4c3b1drv3v2d1p1rdh1w9a0wsxjxpvp4nzwm26h7bvg7n"
  # To determine the name, version, and SHA256 hash of a theme, find it on
  # https://wordpress.org/themes and look at the URL of the "Download" button. Most URLs will tell
  # you the name and version. To determine the hash, install `nix-prefetch-zip`
  # (via `nix-env -i nix-prefetch-zip`) and run it on the theme URL:
  #   `nix-prefetch-zip <URL>`.
  getTheme = name: version: sha256: fetchzip {
    inherit name sha256;
    url = "https://downloads.wordpress.org/theme/${name}.${version}.zip";
  };
}
