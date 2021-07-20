# APSIM Next Generation
#
# A container for running APSIM Next Generation.
#
# To build this container, run this from the ApsimX directory (after building apsim):
#    docker build -t apsiminitiative/apsimng .
# To run the container:
#    docker run -i --rm -v "$PWD:/apsim" apsiminitiative/apsimng path/to/my/file.apsimx

# Build apsim in an intermediate container
FROM mcr.microsoft.com/dotnet/sdk:3.1

# Builder of this image may specify an sha256 (commit hash) and version number of the build.
# These are optional, but if set, the specified commit will be built, and stamped with the
# version number.
ARG sha256
ARG version

RUN git clone https://github.com/APSIMInitiative/ApsimX /apsim
WORKDIR /apsim

# If sha256 variable is set, attempt to checkout the specified commit.
RUN test -z ${sha256:+x} || (echo "Checking out $sha256..." && git checkout $sha256)

# If version variable is set, version stamp the build.
RUN test -z ${version:+x} || (export apsimx=/apsim && echo "Version stamping the build..." && sed -i -e "s/0\.0\.0\.0/$version/g" "$apsimx/Models/Properties/AssemblyVersion.cs" && cp "$apsimx/Models/Properties/AssemblyVersion.cs" "$apsimx/ApsimNG/Properties/")

# Build apsim.
RUN dotnet publish --nologo -c Release -f netcoreapp3.1 -r linux-x64 --no-self-contained /apsim/Models/Models.csproj


# The actual image is based on dotnet/runtime.
FROM mcr.microsoft.com/dotnet/runtime:3.1

# Install sqlite3
RUN apt update -q --silent && \
    apt install -yq libsqlite3-dev

# Copy build artifacts from the intermediate container to /apsim
COPY --from=0 /apsim/bin/Release/netcoreapp3.1/linux-x64/publish /opt/apsim/

# Add apsim to path
ENV PATH $PATH:/opt/apsim

# Set shell to bash (best shell :)
SHELL ["bash"]

# Entrypoint is Models CLI
ENTRYPOINT ["Models"]
