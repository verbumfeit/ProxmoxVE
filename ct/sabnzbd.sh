#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/verbumfeit/ProxmoxVE/refs/heads/add-par2cmdline-turbo/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://sabnzbd.org/

APP="SABnzbd"
var_tags="downloader"
var_cpu="2"
var_ram="4096"
var_disk="8"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
   header_info
   check_container_storage
   check_container_resources
   if [[ ! -d /opt/sabnzbd ]]; then
      msg_error "No ${APP} Installation Found!"
      exit
   fi
   RELEASE=$(curl -fsSL https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
   if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
      msg_info "Updating $APP to ${RELEASE}"
      systemctl stop sabnzbd.service
      tar zxvf <(curl -fsSL https://github.com/sabnzbd/sabnzbd/releases/download/$RELEASE/SABnzbd-${RELEASE}-src.tar.gz)
      cp -rf SABnzbd-${RELEASE}/* /opt/sabnzbd
      rm -rf SABnzbd-${RELEASE}
      cd /opt/sabnzbd
      $STD python3 -m pip install -r requirements.txt
      echo "${RELEASE}" >/opt/${APP}_version.txt
      systemctl start sabnzbd.service
      msg_ok "Updated ${APP} to ${RELEASE}"
   else
      msg_ok "No update required. ${APP} is already at ${RELEASE}"
   fi
   PAR2RELEASE=$(curl -fsSL https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
   if [[ $(par2 --version) != "par2cmdline-turbo version ${PAR2RELEASE}" ]]; then
      msg_info "Updating par2cmdline-turbo to ${PAR2RELEASE}"
      $STD apt-get remove par2 -y
      curl -fsSLO https://github.com/animetosho/par2cmdline-turbo/releases/download/v$PAR2RELEASE/par2cmdline-turbo-v$PAR2RELEASE-linux-amd64.xz
      xz -qdv par2cmdline-turbo-v$PAR2RELEASE-linux-amd64.xz
      chmod +x par2cmdline-turbo-v$PAR2RELEASE-linux-amd64
      mv par2cmdline-turbo-v$PAR2RELEASE-linux-amd64 /usr/bin/par2
      msg_ok "Updated par2cmdline-turbo to ${PAR2RELEASE}"
   else
      msg_ok "No update required. par2cmdline-turbo is already at ${PAR2RELEASE}"
   fi
   exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7777${CL}"
