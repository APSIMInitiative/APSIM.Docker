#!/bin/bash

readonly SCRIPTNAME=$(basename "${0%.sh}")
usage() {
    cat <<-END
NAME
      ${SCRIPTNAME} - Run a graphical APSIM Next Gen instance via Docker.

SYNOPSIS
       ${SCRIPTNAME} [OPTION]...

DESCRIPTION
       Run APSIM Next Gen GUI in a Docker container.

USAGE
       Launch an APSIM Next Gen graphical session with the current directory
       mounted into the container as '/data':

              apsimng-gui.sh

       Launch an APSIM Next Gen graphical session with a specified directory
       mounted into the container as '/data':

              apsimng-gui.sh --data=./project

OPTIONS SUMMARY
       --data            Optional. Directory to mount as '/data'. If not
                         specified, the current/working directory will be used.
       -h, --help        Display this help and exit.

AUTHOR
       Written by Asher Bender.

SEE ALSO
       For more information on APSIM Next Gen visit: <https://www.apsim.info/apsim-next-generation/>
       For APSIM Docker containers visit: <https://hub.docker.com/u/apsiminitiative>

END
}

readonly IMAGE_TAG="apsiminitiative/apsimng-gui:latest"

# ------------------------------------------------------------------------------
#                                 Parse options
# ------------------------------------------------------------------------------

# Define command line argument/options.
OPTIONS="hv"
LONGOPTS="data:,help"

# Parse options and exit on failures.
! OPTS=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 1
fi
eval set -- "$OPTS"

# Collect options.
DATA=$(pwd)
while true; do
    case "$1" in
        --data)          DATA="$2"; shift 2;;
        -h | --help)     usage; exit 0 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

# Convert data directory to absolute path and ensure it exists.
DATA=$(realpath ${DATA})
if [ ! -d ${DATA} ]; then
    echo "The data directory does not exist: ${DATA}."
    exit 1
fi

# ------------------------------------------------------------------------------
#                                 Run container
# ------------------------------------------------------------------------------

xhost +local:docker
docker run --rm -it                                                            \
           -u $(id -u):$(id -g)                                                \
           -e DISPLAY=unix$DISPLAY                                             \
           -v /tmp/.X11-unix:/tmp/.X11-unix                                    \
           -v /etc/localtime:/etc/localtime:ro                                 \
           -v  ${DATA}:/data                                                   \
           -v  /dev/shm:/ApsimInitiative/ApsimX                                \
           ${IMAGE_TAG}
