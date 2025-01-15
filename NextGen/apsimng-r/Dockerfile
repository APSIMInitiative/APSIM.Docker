# R dependencies for running apsim. This image does **not** include APSIM.
#
# This includes:
#
# - R packages for running optimisation/sensitivity analysis
#
# This does /not/ include:
#
# - APSIM
#
# To build this container:
#    docker build -t apsiminitiative/apsimng-r .

FROM mcr.microsoft.com/dotnet/runtime:8.0-bullseye-slim

# Install R 4.X
RUN apt update && \
    apt install -y gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    echo "deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/" | tee /etc/apt/sources.list.d/r-cran40.list && \
    apt update && \
    apt install -yt bullseye-cran40 r-base r-base-dev cmake && \
    apt install -y p7zip-full libcurl4-openssl-dev libssl-dev

# Install R package dependencies
RUN R -q -e 'install.packages(c("remotes", "sensitivity", "RSQLite", "DBI", "DiceDesign", "DHARMa", "gap"), repos = "https://cran.csiro.au/")'

# BayesianTools (a dependency of SticsRPacks) is not currently on cran.
# Therefore we need to install it manually.
RUN R -q -e 'remotes::install_github(repo = "florianhartig/BayesianTools", subdir = "BayesianTools", dependencies = T, build_vignettes = F)'
RUN R -q -e 'remotes::install_github("hol430/ApsimOnR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'
RUN R -q -e 'remotes::install_github("SticsRPacks/CroptimizR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'
