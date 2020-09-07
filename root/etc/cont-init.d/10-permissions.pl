#!/usr/bin/with-contenv bash
set -eux

function reown {
  case $1 in
    "user")
      own="chown ${3}"
      mod="usermod -o -u ${4} ${3}"
      ;;
    "group")
      own="chgrp ${3}"
      mod="groupmod -o -g ${4} ${3}"
      ;;
    *)
      echo "bad argument" >/dev/stderr
      exit 1
      ;;
  esac

  echo "changing uid/gid of ${1} ${3} to ${4}"
  ${mod}

  for path in $(find / -${1} ${2} 2>/dev/null); do
    echo "fixing ownership of ${path}"
    ${own} "${path}"
  done
}

# uid 33: www-data
reown user   33 www-data ${PUID}
reown group  33 www-data ${PGID}

# uid 999: pihole
reown user  999 pihole ${PUID}
reown group 999 pihole ${PGID}
