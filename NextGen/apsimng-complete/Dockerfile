# APSIM Next Generation full dependencies for running/building/testing.
#
# This includes:
# - Runtimes for running APSIM
# - SDKs for building APSIM
# - NUnit console runner
# - R packages for running optimisation/sensitivity analysis
#
# To build this container:
#    docker build -t apsiminitiative/apsimng-complete .
# To run the container:
#    docker run -it --rm --entrypoint=bash apsiminitiative/apsimng-complete

FROM apsiminitiative/apsimng-build:latest

RUN apt install -y r-base r-base-dev p7zip-full

# Install R package dependencies
RUN R -q -e 'install.packages(c("remotes", "sensitivity", "RSQLite", "DBI"), repos = "https://cran.csiro.au/")'
RUN R -q -e 'remotes::install_github("hol430/ApsimOnR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'
RUN R -q -e 'remotes::install_github("SticsRPacks/CroptimizR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'

# The nunit-console package on debian is outdated. We need to do a manual install.
RUN mkdir nunit3-console; \
    cd nunit3-console; \
    wget https://github.com/nunit/nunit-console/releases/download/v3.9/NUnit.Console-3.9.0.zip -qO nunit3-console.zip; \
    unzip -q nunit3-console.zip; \
    rm nunit3-console.zip; \
    mkdir -p /usr/lib/nunit3-console; \
    cp -r -p * /usr/lib/nunit3-console/; \
    echo '#!/bin/sh' >/usr/bin/nunit3-console; \
    echo '# Wrapper script for NUnit 3 console runner' >>/usr/bin/nunit3-console; \
    echo 'exec $(which mono) --debug /usr/lib/nunit3-console/nunit3-console.exe "$@"' >>/usr/bin/nunit3-console; \
    chmod a+x /usr/bin/nunit3-console;

ENTRYPOINT ["dotnet", "/opt/ApsimX/NetCoreBin/Models.dll"]
