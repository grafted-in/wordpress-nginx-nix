Setting Up Secrets
==================

## `.gitignore` configuration

Your `.gitignore` file can mimic the one for this repository, but should at least include the following entries:

    # Nix results and temporary deployment files.
    result
    *.nixops-*

## `git-crypt` setup

Unless you're using a custom solution (e.g. [vault](https://github.com/hashicorp/vault)) for deployment data, deployments will require that you store secrets in your repository. To achieve this, you will need to install [git-crypt](https://www.agwa.name/projects/git-crypt/).

`git-crypt` can use a shared secret or rely on [PGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) identities to securely grant access to the appropriate users. Configuring `git-crypt` is outside the scope of this project, but it's well worth learning if you don't know it already. (It's not that much work to use.) [Keybase](https://keybase.io/) offers excellent tooling and help in the realm of PGP identities and security.

### `.gitattributes` configuration

For `git-crypt`, you will also need to properly configure your `.gitattributes` file. The `.gitattributes` file for this repository serves as a good example. Most importantly, it must contain the following entry:


    # Encrypt all deployment data.
    *.nixops binary filter=git-crypt diff=git-crypt

### Granting PGP access to yourself via Keybase

If you're using Keybase, you grant access to yourself by importing your own key:

```shell
keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key-import --import
git-crypt add-gpg-user <your keybase.io user>
```

### Granting PGP access to a Keybase user

If you're using Keybase, you can grant access to a user like this:

```shell
keybase pgp pull <keybase.io user>
gpg --edit-key <keybase.io user>
  > lsign
  > save
git-crypt add-gpg-user <keybase.io user>
```
