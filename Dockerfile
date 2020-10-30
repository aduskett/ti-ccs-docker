FROM centos:8
LABEL maintainer="Adam Duskett <aduskett@gmail.com>" \
description="Everything needed to run TI CCS10 in a docker container with X11 forwarding."

ARG TI_DL_BASE=https://downloads.ti.com
ARG CCS_VERSION=10.1.1.00004
ARG CL2000_VERSION=18.12.4.LTS
ARG CCS_LINK=${TI_DL_BASE}/ccs/esd/CCSv10/CCS_10_1_1/exports/CCS${CCS_VERSION}_web_linux-x64.tar.gz?tracked=1
ARG CL2000_LINK=${TI_DL_BASE}/codegen/esd/cgt_public_sw/C2000/${CL2000_VERSION}/ti_cgt_c2000_${CL2000_VERSION}_linux_installer_x86.bin?tracked=1
ARG COMPONENT_LIST
ARG CL2000
ARG USERNAME
ARG UID
ARG GID

RUN set -e; \
  dnf update -y; \
  dnf install -y epel-release; \
  dnf install -y dnf-plugins-core; \
  dnf config-manager --set-enabled PowerTools; \
  dnf install -y \
  alsa-lib \
  atk \
  cairo \
  curl \
  dbus-x11 \
  fontconfig \
  freetype \
  GConf2 \
  gdk-pixbuf2 \
  git \
  glibc-devel.i686 \
  gtk2 \
  java-11-openjdk \
  libcanberra \
  libcanberra-gtk3 \
  libglvnd-glx \
  libnsl \
  libusb \
  libX11 \
  libXext \
  libXi \
  libXrender \
  libXScrnSaver \
  libXtst \
  ncurses-compat-libs \
  nspr \
  nss \
  nss-util \
  PackageKit-gtk3-module \
  pango \
  which \
  wget; \
  groupadd -r -g ${GID} ${USERNAME}; \
  useradd -ms /bin/bash -u ${UID} -g ${GID} ${USERNAME}; \
  usermod -aG wheel ${USERNAME}; \
  echo "alias ls='ls --color=auto'" >> /home/${USERNAME}/.bashrc; \
  echo "PS1='\u@\H [\w]$ '" >> /home/${USERNAME}/.bashrc; \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME};

RUN set -e; \
  mkdir -p /tmp/ccs/; \
  mkdir -p /tmp/cl2000; \
  wget ${CCS_LINK} -O /tmp/ccs/ccs.tar.gz; \
  cd /tmp/ccs; \
  tar -zxf ./ccs.tar.gz; \
  echo "Installing ccs, this may take a while, please be patient!"; \
  ./ccs_setup_${CCS_VERSION}.run --mode unattended --enable-components ${COMPONENT_LIST} --prefix /opt/ti/ccs10; \
  if [[ ${CL2000} == "true" ]]; then \
    wget ${CL2000_LINK} -O /tmp/cl2000/cl2000.bin; \
    chmod +x /tmp/cl2000/cl2000.bin; \
    cd /tmp/cl2000; \
    ./cl2000.bin --mode unattended --prefix /opt/ti/cl2000; \
    mv /opt/ti/cl2000/ti-cgt-*/ /opt/ti/cl2000/ti-cgt-c2000; \
    echo "PATH=${PATH}:/opt/ti/cl2000/ti-cgt-c2000/bin" >> /root/.bashrc; \
  fi; \
  cd /tmp; \
  rm -rf /tmp/ccs; \
  rm -rf /tmp/cl2000; \
  printf "#!/usr/bin/env bash\nexport NO_AT_BRIDGE=1\n/opt/ti/ccs10/ccs/eclipse/ccstudio &\n/bin/bash\n" > /init; \
  chmod +x /init;

USER ${USERNAME}
CMD ["/init"]
