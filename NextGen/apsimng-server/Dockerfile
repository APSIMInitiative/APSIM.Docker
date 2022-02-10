# APSIM Next Generation Server container

# We build the server in an intermediate container.
FROM mcr.microsoft.com/dotnet/sdk:3.1
RUN git clone https://github.com/hol430/ApsimX /apsim
ARG nocache
RUN cd /apsim && git fetch origin refactor/Server && git checkout refactor/Server && git log -1
RUN dotnet publish -c Release -r linux-x64 --no-self-contained /apsim/APSIM.Server/APSIM.Server.csproj

# The actual container is based on dotnet/runtime (we don't need the SDK).
FROM mcr.microsoft.com/dotnet/runtime:3.1
WORKDIR /root
RUN apt update -q --silent && apt install -yq vim libsqlite3-dev procps
RUN curl -s -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    curl -s -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    bash -c "sha=$(cat kubectl.sha256) echo "$sha kubectl" | sha256sum --check" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Copy build artifacts from the intermediate container to /apsim
COPY --from=0 /apsim/bin/Release/netcoreapp3.1/linux-x64/publish /apsim/

ENTRYPOINT ["/apsim/apsim-server"]
