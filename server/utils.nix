{
  traced = x: builtins.trace x x;
  required = arg: help: builtins.abort "${arg} is required: ${help}";
}
