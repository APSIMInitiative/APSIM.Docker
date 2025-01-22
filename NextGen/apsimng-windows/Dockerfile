FROM mcr.microsoft.com/dotnet/sdk:8.0

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
  apt update -y && \
  apt install -y --no-install-recommends ca-certificates curl git libvulkan1 osslsigncode unzip wget xauth xvfb

#Setup xvfb and wine
RUN sed -i '/kill ".*"/a wait "$XVFBPID" >>"$ERRORFILE" 2>&1' /usr/bin/xvfb-run && \ 
  sed -i '/^Enabled:/ s/no/yes/' /etc/apt/sources.list.d/* && \
  apt update -y && \
  apt install -y --no-install-recommends wine wine32

ENV DISPLAY=0.0

#Copy in innosetup and unzip program
COPY inno.zip ./
RUN unzip -o inno.zip -d ./inno/

ENTRYPOINT ["/bin/bash"]