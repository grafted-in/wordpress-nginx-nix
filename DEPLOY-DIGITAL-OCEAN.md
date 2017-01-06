Deploying to DigitalOcean
=========================

## Deploying to a DigitalOcean account

If you want to deploy this server to a DigitalOcean account, use the following instructions to configure it:

### Get an API token

Create an API token for the deployment:

  1. In your DigitalOcean account, click **API** in the topmost menu.
  2. Open the **Tokens** tab.
  3. Click *Generate New Token*.
  4. Give your token a name that will describe this project and grant it both "Read" and "Write" scopes.
  5. Click *Generate Token* and copy the resulting token.

Configuring deployment:

  1. Copy `server/digital-ocean.keys.nix.sample` to `server/digital-ocean.keys.nix`.
  2. Replace the `...` with your API token.

### Deploying

To deploy to production, you will use similar steps as deploying to VirtualBox (see the README):

  1. Configure `server/physical.digital-ocean.prod.nix` to your preferences.
  2. `deploy/manage create -d prod '<server/logical.prod.nix>' '<physical.digital-ocean.prod.nix>'`
  3. `deploy/manage export -d prod > deploy/prod.nixops-exported`
  4. `DIGITAL_OCEAN_AUTH_TOKEN=<your-api-token> deploy/manage deploy -d prod`
    * Note: We need to use an environment variable to specify the API token for the time being; future versions of `nixops` will not require this.

It may take a long time to build the server and upload all the dependencies.

**IMPORTANT:** You **must** keep your deployment state in `deploy/prod.nixops-exported` and up-to-date in the repository. Once you run the `deploy/manage export` command above, you must commit that file and always commit it any time you do a deployment that causes it to change. The `deploy/manage` script is designed to keep these state files up-to-date on every deployment so that you can be sure to have the right file in your repository. Do not allow simultaneous deployments and always use the deployment state file that actually corresponds to the state of the server.


### Using an existing deployment

Once you've made a deployment and committed its `.nixops-exported` file to the repository, anyone on your team can deploy who has `git-crypt` access to the file. The steps are just like before:

  1. `deploy/manage info -d prod` (get info about the production deployment)
  2. `deploy/manage deploy -d prod` (deploy to production)
  3. `git add deploy/prod.nixops-exported && git commit -m"Deployment"`
