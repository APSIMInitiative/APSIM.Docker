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
RUN apt install -yq sqlite3

# Copy prebuilt assemblies into the container
COPY NetCoreBin /opt/ApsimX/NetCoreBin/

# Temp hack
RUN ln -s /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /usr/lib/x86_64-linux-gnu/libsqlite3.so

WORKDIR /apsim

# Run APSIM
ENTRYPOINT ["dotnet", "/opt/ApsimX/NetCoreBin/Models.dll"]
