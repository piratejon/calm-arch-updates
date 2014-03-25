#!/bin/sh

sudo pacman -Sy

PKGLIST=packages-`date +%F`
pacman -Qu | awk '{print $1}' > ${PKGLIST}

for pkg in `cat ${PKGLIST}`
do
  for file in `pacman -Ql ${pkg} | cut --complement -d' ' -f1`
  do
    [ -f "${file}" ] && {
      md5sum "${file}" >> "${pkg}-presums"
    }
  done
done

echo y | sudo pacman -Su

for pkg in `cat ${PKGLIST}`
do
  for file in `pacman -Ql ${pkg} | cut --complement -d' ' -f1`
  do
    [ -f "${file}" ] && {
      md5sum "${file}" >> "${pkg}-postsums"
    }
  done
done

