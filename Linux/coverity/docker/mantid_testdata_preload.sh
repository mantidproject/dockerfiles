#!/bin/bash

_infomsg() {

  local readonly msg="$*"
  if echo -n ${msg} | grep -q '\\n'; then
    # enable vertical output padding
    echo -n -e \
      ".\n.\n${BASH_SOURCE[0]##*/} >> [Info] << ${msg}.\n.\n"
  else
    # padding disabled
    echo    "${BASH_SOURCE[0]##*/} >> [Info] << ${msg}"
  fi  
}

main() {

  local count
  local rc

  for count in $(seq -f "%02g" 5 -1 1); do
    _infomsg "${count} attempts remaining"

    _infomsg "attempting download ... " "\n"
    echo "."; echo "."
    echo "wget -r -np --quiet -nH --cut-dirs=1 https://mantid-cache.sns.gov/testdata/MD5/"; $_
    echo "."; echo "."

    [[ ${rc} -ne 0 ]] \
      && _infomsg "download failure, waiting 5 sec ..." \
      && sleep 5 \
      && continue

    [[ ${rc} -eq 0 ]] \
      && _infomsg "success!" "\n" \
      && break
  done

  #
  # need to strip leading zero, e.g. count == 04
  #
  [[ ${count#0} -gt 1 ]] || _infomsg "unable to preload ornl testdata cache"

}

main
