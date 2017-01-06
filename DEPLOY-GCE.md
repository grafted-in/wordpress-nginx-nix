Deploying to Google Compute Engine (GCE)
========================================

## Deploying to a new GCE account

If you want to deploy this server to a new GCE account, use the following instructions to configure it:

### Setting up a new GCE project

Create a Google Cloud Compute project:

  1. Create an account with Google Cloud Compute or sign in with an existing account.
  2. Go to the **Console** for your account.
  3. Under the **Project** menu click *Create Project*, provide a project name, and create the project.
  4. Once created the new project should be selected as the current project in the console.

Create a service account that will run the deployment:

  1. While in your project on Google Cloud Platform, under the "hamburger menu" (pop-in sidebar), select **IAM & Admin** then select *Service accounts*.
  2. Click *CREATE SERVICE ACCOUNT* at the top.
  3. Choose a name for your new service account that reminds you of its function: a deployment manager.
  4. Select both the *Editor* and *Viewer* roles.
  5. Enable the *Furnish a new private key* setting and select the P12 format.
  6. Create the account and remember the key passphrase (probably `notasecret`).
  7. Convert the P12 key to a PEM key by running the following, replacing `{key}` with the name of your key file (without the extension) and `{notasecret}` with the key password:
     `openssl pkcs12 -in {key}.p12 -passin pass:{notasecret} -nodes -nocerts | openssl rsa -out {key}.pem`

Configuring deployment:

  1. Copy `server/gce.keys.nix.sample` to `server/gce.keys.nix`.
  2. Replace the `...` with your project and credentials.


### Deploying

To deploy to production, you will use similar steps as deploying to VirtualBox (see the README):

  1. Configure `server/physical.gce.prod.nix` to your preferences.
  2. `deploy/manage create -d prod '<server/logical.nix>' '<server/physical.gce.prod.nix>'`
  3. `deploy/manage export -d prod > deploy/prod.nixops-exported`
  4. `deploy/manage deploy -d prod`

It may take a long time to build the server and upload all the dependencies.

**IMPORTANT:** You **must** keep your deployment state in `deploy/prod.nixops-exported` and up-to-date in the repository. Once you run the `deploy/manage export` command above, you must commit that file and always commit it any time you do a deployment that causes it to change. The `deploy/manage` script is designed to keep these state files up-to-date on every deployment so that you can be sure to have the right file in your repository. Do not allow simultaneous deployments and always use the deployment state file that actually corresponds to the state of the server.


### Using an existing deployment

Once you've made a deployment and committed its `.nixops-exported` file to the repository, anyone on your team can deploy who has `git-crypt` access to the file. The steps are just like before:

  1. `deploy/manage info -d prod` (get info about the production deployment)
  2. `deploy/manage deploy -d prod` (deploy to production)
  3. `git add deploy/prod.nixops-exported && git commit -m"Deployment"`
