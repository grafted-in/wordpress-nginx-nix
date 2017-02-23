import ./logical.nix (self: super: {
  domain         = "testsite.dev";
  host           = self.domain;
  hostRedirects  = [];
  enableHttps    = false;
  enableRollback = false;
})
