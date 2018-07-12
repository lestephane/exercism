#! /usr/bin/env bash
# 
# https://stackoverflow.com/questions/11930442/make-inotifywait-group-multiple-file-updates-into-one

set -euo pipefail

[ "${DOCKER_MACHINE_NAME}" == "$(docker-machine active)" ] || {
    echo "unable to determine active docker-machine" 1>&2
    exit 1
}

RSYNC_SOURCE_DIRECTORY=$(pwd)
RSYNC_TARGET_DIRECTORY="/$(basename "${RSYNC_SOURCE_DIRECTORY}")"

docker-machine ssh "${DOCKER_MACHINE_NAME}" "sudo mkdir -p \"${RSYNC_TARGET_DIRECTORY}\" && sudo chown docker \"${RSYNC_TARGET_DIRECTORY}\""  

DOCKER_MACHINE_IP="$(docker-machine ip "${DOCKER_MACHINE_NAME}")"

run_rsync() {
    rsync -avzh \
        -e "ssh -i ${HOME}/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa" \
        --progress \
        "${RSYNC_SOURCE_DIRECTORY}/" \
        "docker@${DOCKER_MACHINE_IP}:${RSYNC_TARGET_DIRECTORY}"
}

run_rsync
inotifywait \
    -mr "${RSYNC_SOURCE_DIRECTORY}" \
    -e close_write,moved_to,create,delete \
    --format '%:e %f %T' \
    --timefmt '%H%M%S' | \
        while read event_type event_file event_time; do
    
    current_time=$(date +'%H%M%S')
    time_delta_seconds=$(python -c "print(abs(${current_time} - ${event_time}))")
    
    printf "%-10s %-20s %-50s" $(date --iso-8601) "${event_type}" "${event_file}" 1>&2

    if [ "${time_delta_seconds}" -lt 1 ] ; then
        echo "waiting..." 1>&2
        sleep 1 && run_rsync
    else
        echo "ignored" 1>&2
    fi
done

