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
       Launch a Docker container (apsiminitiative/apsimng-gui:latest) running an
       APSIM Next Gen graphical session.

              apsimng-gui.sh

       Note that the current directory is mounted into the container as '/data'.
       A directory on the host machine can mounted into the container using the
       '--data' option:

              apsimng-gui.sh --data=./project

       To use a specific image tag (apsiminitiative/apsimng-gui:tag), specify
       the tag via the '--tag' option:

              apsimng-gui.sh --tag 7446

       If '--tag' is omitted, 'latest' will be used.

       Local and remote images can be synchronised using the '--update'
       option. For example, to ensure the local 'latest' image matches the
       remote 'latest' image, run:

              apsimng-gui.sh --update


OPTIONS SUMMARY
       --tag       Optional. Specify the image:tag (apsiminitiative/apsimng-gui)
                   to run. If the image tag is not available in the local Docker
                   register, the script will search the remote Docker register
                   (Docker Hub) and pull the image if available. If the tag does
                   not exist locally or on the remote registry, the script will
                   exit. By default the tag is set to 'latest'.
       --update    Optional. If this flag is set and the image tag exists on
                   both the local and remote registries, the remote image will
                   be pulled if the digest sha256 hashes do not match. This flag
                   can be used to ensure local and remote tags, like 'latest',
                   are synchronised.
       --data      Optional. Directory to mount as '/data'. If not specified,
                   the current/working directory will be used.
       -h, --help  Display this help and exit.

AUTHOR
       Written by Asher Bender.

SEE ALSO
       For more information on APSIM Next Gen visit: <https://www.apsim.info/apsim-next-generation/>
       For APSIM Docker containers visit: <https://hub.docker.com/u/apsiminitiative>

END
}

readonly DOCKER_HUB="https://registry.hub.docker.com/v2/repositories"
readonly IMAGE="apsiminitiative/apsimng-gui"

# ------------------------------------------------------------------------------
#                              Script dependencies
# ------------------------------------------------------------------------------

if ! command -v docker &> /dev/null ; then
    echo "This script requires Docker to be installed."
    exit 1
fi

if ! command -v getopt &> /dev/null ; then
    echo "This script requires 'getopt' to be installed."
    exit 1
fi

if ! command -v jq &> /dev/null ; then
    echo "This script requires 'jq' to be installed."
    exit 1
fi

# ------------------------------------------------------------------------------
#                                Local functions
# ------------------------------------------------------------------------------

get_local_hash(){
    # Return the hash of a local image.
    #
    # Query the local registry for an image and tag. If a manifest is returned,
    # it is parsed and the sha256 digest is returned. If no manifest is found,
    # an empty string is returned.
    #
    # Args:
    #     image (str): Name of image on remote registry (Docker Hub).
    #     tag   (str): Tag of image.
    #
    # Returns:
    #     str: sha256 digest if the `image` and `tag` exist on the remote
    #     registry, otherwise the empty string is returned.

    local image="$1"
    local tag="$2"

    manifest=$(docker inspect "${IMAGE}:${TAG}" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo "${manifest}" | jq -r '.[].Id'
    else
        echo ""
    fi
}


get_remote_hash(){
    # Return the hash of a remote image.
    #
    # Query the remote registry (Docker Hub) for an image and tag. If a manifest
    # is returned, it is parsed and the sha256 digest is returned. If no
    # manifest is found, an empty string is returned.
    #
    # Args:
    #     image (str): Name of image on remote registry (Docker Hub).
    #     tag   (str): Tag of image.
    #
    # Returns:
    #     str: sha256 digest if the `image` and `tag` exist on the remote
    #     registry, otherwise the empty string is returned.

    local image="$1"
    local tag="$2"

    manifest=$(docker manifest inspect ${image}:${tag} 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo "${manifest}" | jq -r '.config.digest'
    else
        echo ""
    fi
}

# ------------------------------------------------------------------------------
#                                 Parse options
# ------------------------------------------------------------------------------

# Define command line argument/options.
OPTIONS="hv"
LONGOPTS="tag:,update,data:,help"

# Parse options and exit on failures.
! OPTS=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 1
fi
eval set -- "$OPTS"

# Collect options.
TAG='latest'
DATA=$(pwd)
UPDATE=0
while true; do
    case "$1" in
        --tag)    TAG="$2";  shift 2;;
        --update) UPDATE=1;  shift ;;
        --data)   DATA="$2"; shift 2;;
        -h | --help) usage; exit 0 ;;
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
#                              Acquire/update image
# ------------------------------------------------------------------------------

echo "Searching registries for '${IMAGE}:${TAG}'."
echo -n "    Searching local  registry."
local_hash=$(get_local_hash "${IMAGE}" "${TAG}")

# Check local repository for image.
if [ ! -z "${local_hash}" ]; then
    echo " Image found."
else
    echo " Image not found".
fi

# If the local repository does not exist OR the local repository exists and the
# user has requested an update.
remote_hash=""
if [ -z "${local_hash}" ] || { [ ! -z "${local_hash}" ] && [ ${UPDATE} -eq 1 ]; }; then
    echo -n "    Searching remote registry."
    remote_hash=$(get_remote_hash "${IMAGE}" "${TAG}")

    if [ ! -z "${remote_hash}" ]; then
        echo " Image found."
    else
        echo " Image not found".
    fi
fi


# The image could be found on both the local and remote registries.
if [ ! -z "${local_hash}" ] && [ ! -z "${remote_hash}" ]; then

    if [[ "${local_hash}" == "${remote_hash}" ]] ; then
        echo "    The local and remote images have an identical hash."
        echo "        local:  ${local_hash}"
        echo "        remote: ${remote_hash}"
    else
        echo "    The local and remote images have different hashes."
        echo "        local:  ${local_hash}"
        echo "        remote: ${remote_hash}"
        if [ ${UPDATE} -eq 1 ] ; then
            echo "    Pulling remote image."
            docker pull "${IMAGE}:${TAG}"
        fi
    fi

# The image could only be found on the remote registry.
elif [ -z "${local_hash}" ] && [ ! -z "${remote_hash}" ]; then
    echo "Pulling remote image."
    docker pull "${IMAGE}:${TAG}"

# The image could not be found on either the local or remote registries.
elif [ -z "${local_hash}" ] && [ -z "${remote_hash}" ]; then
    echo "The image '${IMAGE}:${TAG}' could not be found."
    exit 1

# The image could only be found on the local registry. This condition should not
# happen. We know 'apsiminitiative/apsimng-gui' exists! Use local image.
else
    :
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
           ${IMAGE}:${TAG}
