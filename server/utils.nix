{
  traced = x: builtins.trace x x;
  required = arg: help: builtins.abort "${arg} is required: ${help}";

  # Converts a set into a string
  #   pkgs  is nixpkgs
  #   sep   is a string separator to place between each field
  #   mapFn is (string -> string -> string) taking key and value for each attribute
  #   attrs is the set to process
  setToString = pkgs: sep: mapFn: attrs: pkgs.lib.concatStringsSep sep (
    pkgs.lib.mapAttrsToList
      (key: val: if builtins.isInt val || builtins.isString val then mapFn key val else "")
      attrs
  );
}
