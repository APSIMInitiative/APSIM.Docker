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

FROM mcr.microsoft.com/dotnet/runtime:10.0.14-noble

COPY install.sh .
RUN chmod +x install.sh
RUN ./install.sh

RUN apt install -y r-base r-base-dev cmake p7zip-full libcurl4-openssl-dev libssl-dev curl libxml2-dev libxslt1-dev

# Install R package dependencies
RUN R -q -e 'install.packages(c("remotes", "sensitivity", "RSQLite", "DBI", "DiceDesign", "DHARMa", "gap"), repos = "https://cran.csiro.au/")'

# BayesianTools (a dependency of SticsRPacks) is not currently on cran.
# Therefore we need to install it manually.
RUN R -q -e 'remotes::install_github(repo = "florianhartig/BayesianTools", subdir = "BayesianTools", dependencies = T, build_vignettes = F)'
RUN R -q -e 'remotes::install_github("APSIMInitiative/ApsimOnR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'
RUN R -q -e 'remotes::install_github("SticsRPacks/SticsRPacks", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'
RUN R -q -e 'remotes::install_github("SticsRPacks/CroptimizR", INSTALL_opts = c("--no-docs", "--no-help", "--no-html"), repos = "https://cran.csiro.au/")'