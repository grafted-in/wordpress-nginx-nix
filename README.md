# [Nix](https://nixos.org/nix/) Setup for [Wordpress CMS](https://wordpress.org/)

This repository contains everything necessary to test and deploy fully operational web servers for [Wordpress CMS](https://wordpress.com/) sites.

This setup uses the powerful [Nix](https://nixos.org/nix/) package management system and its accompanying toolset:

  - [NixOps](https://nixos.org/nixops/) for deployments
  - [NixOS](https://nixos.org/) as the Linux-based server OS

**Note:** Nix does not support Windows. If you're on Windows, you'll need to run this from within a Virtual Machine (VM).

With this setup, you can easily deploy your site to one or more servers with minimal effort. You can (and should) also deploy to local [VirtualBox](https://www.virtualbox.org/) virtual machines. And, you can even use the Nix packages to install the site directly on your local host.

## Features

  * Automatically builds a working server with Nginx, PHP-FPM, MySQL, and WordPress.
  * Automatically configures TLS/SSL using [Let's Encrypt](https://letsencrypt.org/).
  * Configures PHP OpCache and a WordPress plugin to manage it.
  * Configures Nginx Fastcgi-cache with a cache-purging module and a WordPress plugin to manage it.
  * Installs and configures Google's PageSpeed Nginx module.
  * Allows WordPress configuration (settings, versions, plugins, themes, etc.) to be managed entirely by Nix. This means:
    * Upgrades and changes can be tracked in version control.
    * Deployments are reproducible for testing (e.g. in VirtualBox or on a staging server).
    * Security is enhanced by having most PHP files read-only.
  * Highly configurable: most of these settings can be tweaked easily.


## Requirements

  1. First install [Nix](https://nixos.org/nix/). It is not invasive and can be removed easily if you change your mind (using `rm -r /nix`).
  2. Deployments are done with [NixOps](https://nixos.org/nixops/). You can install `nixops` with `nix` by running `nix-env -i nixops`. However, you don't need to because this repository has a `deploy/manage` script that you'll use which will run `nixops` tasks for you.
  3. Install [VirtualBox](https://www.virtualbox.org/) in order to test your server deployments.
  4. If you plan to deploy to a real server, you will likely need to keep secrets in this repository. That will require installing [git-crypt](https://www.agwa.name/projects/git-crypt/) and setting it up. See `SETUP-SECRETS.md` for information on that.

### Attention macOS Users!

This project requires that you build Linux binaries which can be deployed to a server (VirtualBox or otherwise). Since macOS cannot natively build Linux binaries, you will need a NixOS build slave running.

  1. Install [Docker](https://www.docker.com/) and then use [this script](https://github.com/LnL7/nix-docker/blob/master/start-docker-nix-build-slave) to set up a NixOS build slave. For example:
    * `source <(curl -fsSL https://raw.githubusercontent.com/LnL7/nix-docker/master/start-docker-nix-build-slave -o ~/start-docker-nix-build-slave)`
    * `deploy/manage vbox deploy` (or some other deployment command)
  2. If you can't/don't want to install Docker, you can use NixOps to create a NixOS build slave via VirtualBox using [this](https://github.com/3noch/nix-vbox-build-slave). Note that using Docker is almost certainly going to be easier so I recommend that way instead.


## Setting Up WordPress

  1. Create unique WordPress keys for your site (must be in the same directory as `default-app-config.nix`):
    * `curl https://api.wordpress.org/secret-key/1.1/salt/ > wordpress-keys.php.secret`.
  2. Configure your site by editing `default-app-config.nix`.
    * For a traditional install where WordPress is entirely managed by the admin panel, use `freezeWordPress = false;`.
    * To have Nix manage themes but not plugins, you can use `freezeWordPress = true; freezeThemes = true; freezePlugins = false;`.
    * When WordPress is frozen (i.e. managed by Nix), use `wordpress.nix` to govern the installed version.
    * When plugins are frozen (i.e. managed by Nix), use `plugins.nix` to govern which plugins are installed.
    * When themes are frozen (i.e. managed by Nix), use `themes.nix` to govern which themes are installed.
  3. More complex settings can be managed in `server/`.
    * For example, change PHP-FPM configuration in `server/php-fpm-config.nix`.


## Deploying to VirtualBox

Create a VirtualBox deployment:

  1. `deploy/manage vbox create '<server/logical.vbox.nix>' '<server/physical.vbox.nix>'`
  2. `deploy/manage vbox deploy`

**Notes:**

  * `nixops` deployments can sometimes be finicky. If something hangs or fails, try running it again. It is a very deterministic system so this should not be a problem.
  * Run `deploy/manage --help` to see all options (this is just `nixops` underneath).

You should then be able to open the IP of the VM in your browser and test it. If you don't know the IP, run `deploy/manage vbox info`.


### Troubleshooting

  * If you're on macOS (Darwin), be sure you have a NixOS build slave set up as described above.
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
