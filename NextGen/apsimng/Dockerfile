# APSIM Next Generation
#
# A container for running APSIM Next Generation.
#
# To build this container, run this from the ApsimX directory (after building apsim):
#    docker build -t apsiminitiative/apsimng -f ../APSIM.Docker/NextGen/apsimng/Dockerfile .
# To run the container:
#    docker run -i --rm -v "$PWD:/apsim" apsiminitiative/apsimng path/to/my/file.apsimx

FROM mcr.microsoft.com/dotnet/core/runtime

# Install some packages
RUN apt update
RUN apt install -yq libsqlite3-dev

SHELL ["bash", "-c"]

# Get latest version from website.
RUN req=http://apsimdev.apsim.info/APSIM.Builds.Service/Builds.svc/GetLatestVersion && \
    version=$(curl -sS $req | sed -e 's/<[^>]*>//g') && \
    issue=$(echo $version | cut -d'.' -f4) && \
    url=https://apsimdev.apsim.info/ApsimXFiles/apsim-$issue.deb && \
    inst=apsim.deb && \
    curl -sSo "$inst" "$url" && \
    dpkg --force-depends -i "$inst" && \
    rm "$inst" && \
    rm -rf /usr/local/lib/apsim/$version/{Examples,UnderReview,ApsimNG};

WORKDIR /apsim

# Run APSIM
ENTRYPOINT ["Models"]
