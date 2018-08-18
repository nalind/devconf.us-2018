# devconf.us-2018
Content from my 2018 devconf.us talk

* `config.json`:
  - A default for an image's configuration blob.
* `manifest.json`:
  - A default for an image's manifest.

* `date.sh`:
  - Runs `date`, specifying the right format for use in JSON.
* `clean-links.sh
  - Removes symbolic links from the current directory.
* `fixup.sh
  - Removes symbolic links from the current directory.
  - Digests all .tar, .tar.\*, and .json files in the current directory.
  - Creates symbolic links named after the digests that point to those files.

* `unshare2.sh`:
  - Wraps unshare(1).
  - If invoked with -U and not with -r, maps the current user's UID and primary
    GID to 0, and uses newuidmap/newgidmap to map ranges in /etc/subuid and
    /etc/subgid, in sequence, into the namespace, starting with 1, 

* `dnf-install.sh`:
  - Invokes dnf with some flags which should help in populating a chroot
    environment in ./root.  Can be run under `unshare2.sh -U`.
