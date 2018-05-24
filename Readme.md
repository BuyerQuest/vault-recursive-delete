# Vault Recursive Delete

**vault-recursive-delete** is a ruby script that will discover all of the subpaths of a given path in vault, then delete them for you.  It's like `rm -rf /path/to/folder`, but for Vault entries.

## Requirements

* ruby with bundler
* vault binaries (you should be able to `vault list secret/` from your command line)

## Usage

Clone this repository to your machine:

```shell
git clone https://github.com/BuyerQuest/vault-recursive-delete.git
```

Enter the directory and run `bundle install`:

```shell
cd vault-recursive-delete/
bundle install
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

```console
$ git clone https://github.com/BuyerQuest/vault-recursive-delete.git
Cloning into 'vault-recursive-delete'...
remote: Counting objects: 13, done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 13 (delta 2), reused 10 (delta 2), pack-reused 0
Unpacking objects: 100% (13/13), done.

$ cd vault-recursive-delete/

$ bundle install
Fetching gem metadata from https://rubygems.org/................
Resolving dependencies...
Using OptionParser 0.5.1
Using bundler 1.16.0
Using vault 0.10.1
Bundle complete! 2 Gemfile dependencies, 3 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.

$ export VAULT_ADDR=https://redacted.vault.url

$ vault auth -method=ldap username=fake.username
Successfully authenticated! You are now logged in.
#<snip>

$ ./vault-recursive-delete.rb -p secret/foo/ --force
Removing key secret/foo/path/key1: succeeded
Removing key secret/foo/path/key2: succeeded
Removing key secret/foo/key1: succeeded
Removing key secret/foo/key2: succeeded
Removing path secret/foo/path/: succeeded
Removing path secret/foo/: succeeded
```

## Arguments

Use the `--help` switch:

```console
17:09 $ ./vault-recursive-delete.rb --help
Recursive delete for paths in vault.

Usage: ./vault-recursive-delete.rb [options]
    -a, --vault-address=[VAULT_ADDR] URL used to access the Vault server. Defaults to the VAULT_ADDR environment variable
    -t, --vault-token=[VAULT_TOKEN]  A vault token. Defaults to VAULT_TOKEN environment variable, or reads ~/.vault-token
    -p, --path=PATH                  Path in vault to delete from, with a trailing slash. E.g. secret/foo/
        --force                      Suppress confirmation and delete automatically. Use carefully.

    -h, --help                       Display this help
    -v, --version                    Display the current script version
```
