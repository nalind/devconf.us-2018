#!/bin/bash -x

dateformat="%Y-%m-%dT%H:%m:%S.%NZ"
thendate=$(date -u +${dateformat})
nowdate=$(date -u +${dateformat})
author="[Nalin Dahyabhai <nalin@redhat.com>] [A Cast of Tens <root@localhost>]"
substitutions="-e s%@now@%${nowdate}%g -e s%@then@%${thendate}%g"

# Remove any symbolic links in the current directory.
find -maxdepth 1 -type l | xargs -r rm -v

# Compute the sizes and digests of the layers.
declare -a digests diffids sizes dates
layer=1
while test -s layer${layer}.tar.gz ; do
	layerfile=layer${layer}.tar.gz
	digest=sha256:$(sha256sum -b ${layerfile} | cut -c-64)
	diffid=sha256:$(gzip -dc ${layerfile} | sha256sum -b - | cut -c-64)
	size=$(stat -c %s ${layerfile})
	date=$(date -u +${dateformat} -r ${layerfile})
	digests[${#digests[*]}]=${digest}
	diffids[${#diffids[*]}]=${diffid}
	sizes[${#sizes[*]}]=${size}
	dates[${#dates[*]}]=${date}
	substitutions="${substitutions} -e s%@layer${layer}digest@%${digest}%g"
	substitutions="${substitutions} -e s%@layer${layer}diffid@%${diffid}%g"
	substitutions="${substitutions} -e s%@layer${layer}size@%${size}%g"
	substitutions="${substitutions} -e s%@layer${layer}date@%${date}%g"
	# Create a symbolic link for the layer blob with the name that skopeo expects.
	ln -s ${layerfile} $(sha256sum -b ${layerfile}| cut -c-64)
	layer=$((${layer}+1))
done

# Substitute diff IDs, timestamps, and author information to create the final config blob.
sed ${substitutions} -e "s%@author@%${author}%g" config.json.in > config.json
configdigest=sha256:$(sha256sum -b config.json | cut -c-64)
configsize=$(stat -c %s config.json)
substitutions="${substitutions} -e s%@configdigest@%${configdigest}%g"
substitutions="${substitutions} -e s%@configsize@%${configsize}%g"

# Create a symbolic link for the config blob with the name that skopeo expects.
ln -s config.json $(sha256sum -b config.json | cut -c-64)

# Substitute digests, timestamps, and author information to create the final manifest.
sed ${substitutions} -e "s%@author@%${author}%g" manifest.json.in > manifest.json
