#!/bin/bash
set -eu

# reown <user|group> [NAME] [NEW ID]
function reown {
    kind="$1"
    name="$2"
    new="$3"

    case "$kind" in
        user)
            old=$(getent passwd "$name" | cut -d: -f3)
            own="chown"
            mod="usermod -o -u"
            ;;
        group)
            old=$(getent group "$name" | cut -d: -f3)
            own="chgrp"
            mod="groupmod -o -g"
            ;;
        *)
            echo "bad argument" >/dev/stderr
            exit 1
            ;;
    esac

    if [ $old -eq $new ]; then
        echo "not changing id of $kind $name, it already matches host"
        return
    fi

    echo "changing id of $kind $name from $old to $new"
    $mod $new $name

    for path in $(find / "-$kind" "$old" 2>/dev/null); do
        echo "fixing ownership of $path"
        $own "$name" "$path"
    done
}

# TODO: We shouldn't assign these accounts the same UIDs
[[ -n ${WWWDATA_UID+x} ]] && reown user  www-data ${WWWDATA_UID}
[[ -n ${WWWDATA_GID+x} ]] && reown group www-data ${WWWDATA_GID}

[[ -n ${PIHOLE_UID+x} ]] && reown user  pihole ${PIHOLE_UID}
[[ -n ${PIHOLE_GID+x} ]] && reown group pihole ${PIHOLE_GID}
