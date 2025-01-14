# APSIM Next Generation build dependencies
#
# This image includes:
#
# - SDKs for building APSIM
# - Dependencies for constructing APSIM installers
#
# To build this container:
#    docker build -t apsiminitiative/apsimng-build .
# To run the container, run this command from the ApsimX directory:
#    docker run -i --rm -v "$PWD:/apsim" apsiminitiative/apsimng-build

FROM apsiminitiative/apsimng-complete:latest

RUN apt install -y apt-transport-https dirmngr gnupg ca-certificates wget git libgdiplus

# Install latest mono from their repo
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF; \
echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list; \
apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'; \
echo "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/" | tee /etc/apt/sources.list.d/r-cran40.list

# Install microsoft's signing key
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb; \
dpkg -i packages-microsoft-prod.deb; \
rm packages-microsoft-prod.deb

# Update package repos and install build dependencies.
# We need rsync 3.2.3 or newer, which is currently not available in debian stable.
# cmake required to build libdmg-hfsplus
RUN echo "deb http://deb.debian.org/debian testing main" >>/etc/apt/sources.list && \
    apt update && \
    apt install -y -t testing rsync && \
    apt install -y dotnet-sdk-8.0 genisoimage cmake

# Manually install a cut-down version of libdmg-hfsplus, which contains only the
# dmg tool which will compress our .dmg mac installer.
RUN git clone https://github.com/fanquake/libdmg-hfsplus /opt/libdmg-hfsplus && \
    cd /opt/libdmg-hfsplus && \
    cmake . && \
    make && \
    mv dmg/dmg /usr/bin/dmg && \
    cd .. && rm -rf /opt/libdmg-hfsplus

# Add libdmg-hfsplus tool to PATH.
ENV PATH="${PATH}:/opt/libdmg-hfsplus/dmg"

# Opt out of microsoft's telemetry program
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

ENTRYPOINT ["dotnet", "build", "-v", "m", "--nologo"]
