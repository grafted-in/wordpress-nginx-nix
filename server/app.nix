with import ./utils.nix;
let
  writeableDefault = {
    appPaths = [];           # list of paths in the app to make writeable
    pkgPath  = "_writeable"; # path to create in read-only package that stores original content of writeable paths
    sysPath  = required "writeable.sysPath" ''system path to store writeable data (e.g. "/var/lib/phpfpm/my-app")'';
    owner    = required "writeable.owner"   "user which owns the writeable files";
  };
in
{ callPackage
, lib
, runCommand
, writeScript
, writeText

, appConfig
, writeable ? writeableDefault
, ...
}:
let
  # Merge the given writeable settings with the defaults.
  writeable_ = writeableDefault // writeable;

  # We only care about writeble paths if the app is mostly frozen.
  writeablePaths = lib.optionals appConfig.freezeWordPress (
      ["wp-content/uploads"]
      ++ lib.optional (!appConfig.freezePlugins) "wp-content/plugins"
      ++ lib.optional (!appConfig.freezeThemes)  "wp-content/themes"
      ++ writeable_.appPaths
    );

  wordpress = callPackage appConfig.wordpress {};
  plugins   = callPackage appConfig.plugins {};
  themes    = callPackage appConfig.themes {};

  # The wp-config.php file.
  wpConfigFile = writeText "wp-config.php" appConfig.wpConfig.rendered;

  # Generates a list of paths in bash that can be looped over.
  listOfPaths = lib.concatMapStringsSep " " (x: "'${x}'");

  # Generates the bash command to install a path from source to destination.
  # If the install is `frozen`, then we simply symlink, otherwise we copy.
  installPath = isFrozen: from: to:
    (if isFrozen then "ln -s" else "cp -r") + " " + ''"${from}" "${to}"'';

  # The build script for the app.
  # This will install WordPress, the wp-config, plugins, and themes.
  # If any writeble paths were configured, this script will copy them to a another folder in the
  # package and set up symlinks in their place the given writeable path on the system.
  buildPackageAt = out: ''
    mkdir -p $(dirname "${out}")  # Make parent directory.

    cp -r "${wordpress}" "${out}"
    chmod -R +w "${out}"

    ${installPath appConfig.freezeWordPress wpConfigFile "${out}/wp-config.php"}

    # Install themes.
    rm -r "${out}/wp-content/themes"/*  # remove bundled themes
    ${lib.concatMapStringsSep "\n" (x: installPath appConfig.freezeThemes x "${out}/wp-content/themes/${x.name}") themes}

    # Install plugins.
    rm -r "${out}/wp-content/plugins"/* # remove bundled plugins
    ${lib.concatMapStringsSep "\n" (x: installPath appConfig.freezePlugins x "${out}/wp-content/plugins/${x.name}") plugins}

    # TODO: Support translations.

    ${lib.optionalString (writeablePaths != []) ''
      # Make symlinks to writeable directories.
      writeable_orig_dir="${out}/${writeable_.pkgPath}"
      mkdir -p "$writeable_orig_dir"

      for thing in ${listOfPaths writeablePaths}; do
        original_thing="$writeable_orig_dir/$thing"
        parent=$(dirname "$original_thing")
        mkdir -p "$parent"

        # Move any existing data to the frozen writeable dir or create empty directory there.
        mv "${out}/$thing" "$parent" || mkdir -p "$original_thing"

        ln -s "${writeable_.sysPath}/$thing" "${out}/$thing"
      done
    ''}
  '';

  # Copy the original writeable contents of the package to a writeable dir.
  initWriteablePathsFor = package: ''
    mkdir -p "$out"
    writeable_orig_dir="${package}/${writeable_.pkgPath}"
    for thing in $( ls "$writeable_orig_dir" ); do
      cp -r "$writeable_orig_dir/$thing" "$out"
    done
  '';

  # Takes an existing script and makes a initialization script that only runs if the output path
  # has not been built yet.
  mkInitScript = script: writeScript "init-writeable-paths" ''
    #!/bin/sh

    out="${writeable_.sysPath}"

    if [ ! -d "$out" ]; then

      ${script}

      chown -R "${writeable_.owner}" "$out"
      chmod -R 744 "$out"

    else
      echo Output directory already exists. Not building path: "$out"
    fi
  '';

in if appConfig.freezeWordPress
  then rec {
    # For a mostly frozen app, we install it as a package and set up writeable paths on first run.
    initScript = mkInitScript (initWriteablePathsFor package);
    package    = runCommand "wordpress-app" {
      preferLocalBuild = true;
    } (buildPackageAt "$out");
  }
  else rec {
    # For fully writeable app, we skip package installation and write the app directly to the
    # writeable path on first run.
    initScript = mkInitScript (buildPackageAt package);
    package    = writeable_.sysPath;
  }
