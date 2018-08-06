# devconf.us-2018
Content from my 2018 devconf.us talk

* `fixup.sh`:
  - preprocess `config.json.in` to create `config.json`:
    - compute diff IDs for `layer*.tar.gz`, substitute them
    - substitute the author's name and the current date
  - preprocess `manifest.json.in` to create `manifest.json`:
    - substitute the digests and sizes of `layer*.tar.gz`
    - substitute the digest and size of `config.json`

* `layer1.tar.gz`: an empty layer
  - created with `gzip < /dev/null > layer1.tar.gz`

* `layer2.tar.gz`: a layer that we can generate
  * `make-layer2-1.sh`:
    * copies /usr/sbin/busybox from host into /bin under the root
    * the resulting content is owned by my user ID
  * `make-layer2-2.sh`:
    * copies /usr/sbin/busybox from host into /bin under the root
    * uses `unshare` to run `tar`; the resulting content is owned by root
  * `make-layer2-3.sh`:
    * uses `dnf` to install packages into the root
    * uses `unshare` to run `dnf` and `tar`; the resulting content is owned by "root"
    * `unshare` only maps a single ID, so packages which contain content not owned by mapped IDs fail to install
  * `make-layer2-4.sh`:
    * uses `dnf` to install packages into the root
    * uses `buildah unshare` to run `dnf` and `tar`; the resulting content is owned by "root"
