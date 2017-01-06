Setting Up Secrets
==================

## `.gitignore` configuration

No matter what, your first line of defense will be to guard against committing sensitive data to the repository.

Your `.gitignore` file can mimic the one for this repository, but should at least include the following entries:

    # Nix results and hidden deployment data should be ignored.
    result
    .*.nixops*

## `git-crypt` setup

Unless you're using a custom solution for deployment data, deployments will require that you store secrets in your repository. To achieve this, you will need to install [git-crypt](https://www.agwa.name/projects/git-crypt/).

`git-crypt` can use a shared secret or rely on [PGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) identities to securely grant access to the appropriate users. Configuring `git-crypt` is outside the scope of this project, but it's well worth learning if you don't know it already. (It's not that much work to use.) [Keybase](https://keybase.io/) offers excellent tooling and help in the realm of PGP identities and security.

## `.gitattributes` configuration

For `git-crypt`, you will also need to properly configure your `.gitattributes` file. The `.gitattributes` file for this repository serves as a good example. Most importantly, it must contain the following entry:

    # Encrypt all deployment data.
    *.nixops*  filter=git-crypt diff=git-crypt
