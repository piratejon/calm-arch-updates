#!/bin/sh

update_repositories () {
  sudo pacman -Sy
}

date_based_folder () {
  _today=`date +%F`
  _try=${_today}
  _i=0
  while [ -e ${_try} ]
  do
    _try="${_today}${_i}"
  done

  mkdir "${_try}" && {
    OUTDIR="${_try}"
  } || {
    echo "Error: couldn't make ${_try}" 1>&2
    exit 1
  }
}

date_based_folder

echo "Outputting to ${OUTDIR}"

PKGLIST="${OUTDIR}/packages"
STDOUT="${OUTDIR}/stdout"
STDERR="${OUTDIR}/stderr"

save_package_list () {
  pacman -Qu | awk '{print $1}' > ${PKGLIST}
}

make_great_hashes () {
  _suffix="${1}"
  for _pkg in `cat ${PKGLIST}`
  do
    for _file in `pacman -Ql ${_pkg} | cut --complement -d' ' -f1`
    do
      [ -f "${_file}" ] && {
        sudo sha256sum "${_file}"
      }
    done > "${OUTDIR}/${_pkg}-${_suffix}"
  done
}

do_a_real_update () {
  echo y | sudo pacman -Su 2>${STDERR} | tee ${STDOUT}
}

update_repositories
save_package_list
make_great_hashes presums
do_a_real_update
make_great_hashes postsums

