## Description

**vault-recursive-delete** is a ruby script that will walk all of the subpaths of a given path in vault, and delete them for you.  It's like `rf -rf /path/to/folder`, but for Vault entries.

## Requirements

* ruby with bundler
* vault binaries (you should be able to `vault list secret/` from your command line)

## Usage

Clone this repository to your machine:

```shell
git clone https://github.com/BuyerQuest/vault-recursive-delete.git
```

Enter the directory and run `bundler install`:

```shell
cd vault-recursive-delete/
bundler install
```

Authenticate to your vault server (use what's appropriate for your setup):
```shell
export VAULT_ADDR=https://my.vault.server
vault auth -method=ldap username=my.username
```

Invoke the script (the trailing slash is important):
```shell
./vault-recursive-delete.rb -p secret/foo/
```

## Example

```shell
17:09 $ ./vault-recursive-delete.rb -p secret/foo/ --force
Removing key secret/foo/path/key1: succeeded
Removing key secret/foo/path/key2: succeeded
Removing key secret/foo/key1: succeeded
Removing key secret/foo/key2: succeeded
Removing path secret/foo/path/: succeeded
Removing path secret/foo/: succeeded
```

## Arguments

Use the `--help` switch:

```shell
17:09 $ ./vault-recursive-delete.rb --help
Recursive delete for paths in vault.

Usage: ./vault-recursive-delete.rb [options]
    -a, --vault-address=[VAULT_ADDR] URL used to access the Vault server. Defaults to the VAULT_ADDR environment variable if not set
    -p, --path=PATH                  Path in vault to delete from, with a trailing slash. E.g. secret/foo/
        --force                      Suppress confirmation and delete automatically. Use carefully.

    -h, --help                       Display this help
    -v, --version                    Display the current script version
```
