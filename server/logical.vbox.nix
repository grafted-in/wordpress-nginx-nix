import ./logical.nix {
  host           = "testsite.dev";
  hostRedirects  = [];
  adminEmail     = "admin@graftedindesign.com";
  enableHttps    = false;
  enableRollback = false;
}
