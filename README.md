# [Nix](https://nixos.org/nix/) Setup for [Wordpress CMS](https://wordpress.org/)

This repository contains everything necessary to test and deploy fully operational web servers for [Wordpress CMS](https://wordpress.com/) sites.

This setup uses the powerful [Nix](https://nixos.org/nix/) package management system and its accompanying toolset:

  - [NixOps](https://nixos.org/nixops/) for deployments
  - [NixOS](https://nixos.org/) as the Linux-based server OS

**Note:** Nix does not support Windows. If you're on Windows, you'll need to run this from within a Virtual Machine (VM).

With this setup, you can easily deploy your site to one or more servers with minimal effort. You can (and should) also deploy to local [VirtualBox](https://www.virtualbox.org/) virtual machines. And, you can even use the Nix packages to install the site directly on your local host.


## Requirements

  1. First install [Nix](https://nixos.org/nix/). It is not invasive and can be removed easily if you change your mind (using `rm -r /nix`).

  2. Deployments are done with [NixOps](https://nixos.org/nixops/). You can install `nixops` with `nix` by running `nix-env -i nixops`. However, you don't need to because this repository has a `deploy/manage` script that you'll use which will run `nixops` tasks for you.

  3. Install [VirtualBox](https://www.virtualbox.org/) in order to test your server deployments.

  4. If you plan to deploy to a real server, you will likely need to keep secrets in this repository. That will require installing [git-crypt](https://www.agwa.name/projects/git-crypt/) and setting it up. See `SETUP-SECRETS.md` for information on that.


## Setting Up WordPress

  1. Create unique WordPress keys for your site: `curl https://api.wordpress.org/secret-key/1.1/salt/ > deploy/wordpress-keys.php.secret`.
  2. Configure your site by editing `default-app-config.nix`.


## Deploying to VirtualBox

Create a VirtualBox deployment:

  1. `deploy/manage vbox create '<server/logical.vbox.nix>' '<server/physical.vbox.nix>'`
  2. `deploy/manage vbox deploy`

**Notes:**

  * `nixops` deployments can sometimes be finicky. If something hangs or fails, try running it again. It is a very deterministic system so this should not be a problem.
  * Run `deploy/manage --help` to see all options (this is just `nixops` underneath).

You should then be able to open the IP of the VM in your browser and test it. If you don't know the IP, run `deploy/manage vbox info`.


### Troubleshooting

  * If you're on macOS (Darwin), `nixops` needs to build Linux packages. Usually it's able to get them from a cache or build them on the remote server. However, if you get an error about not being able to build a package because you're on "darwin", then **deploy to VirtualBox first and try again.** This will often offload the Linux builds to the VM and then your real deployment will work. If even *this* doesn't work you can use [this](https://github.com/3noch/nix-vbox-build-slave) to create a VirtualBox build slave.
  * If the state of your VirtualBox VM changes in a way that `nixops` didn't notice, your deployments may fail. Try running `deploy/manage deploy -d vbox --check` (using the `--check` flag) to tell `nixops` to reassess the state of the machine.
  * Sometimes VirtualBox will give your machine a new IP. If this happens, `nixops` (i.e. the `manage` script) may fail to connect to your machine via SSH. If this happens, remove the line with the old IP from your `~/.ssh/known_hosts` file and try again with the `--check` flag.


## Deploying to Real Servers

With this setup you can deploy to any PaaS/IaaS service supported by `nixops`. Right now this repository contains prewritten configurations for

  * Google Cloud Compute's [Google Compute Engine (GCE)](https://cloud.google.com/compute/) - see `DEPLOY-GCE.md`.
  * [DigitalOcean](https://www.digitalocean.com/) - see `DEPLOY-DIGITAL-OCEAN.md`.

We plan to add more (such as AWS) in the future. If you want to do it yourself and understand Nix, the work to add this configuration is minimal. Pull requests welcome!


## Keeping Secrets

This repository setup assumes you want to keep some things a secret. See `SETUP-SECRETS.md` for a rundown of how that works.


## Acknowledgements

  * The server setup is highly influenced by
    * https://github.com/nystudio107/nginx-craft
    * https://www.nginx.com/blog/9-tips-for-improving-wordpress-performance-with-nginx/
    * https://easyengine.io/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/
  * Special thanks to @khalwat
