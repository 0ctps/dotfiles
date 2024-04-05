# sshfs - mount
function sshmount() {
  hostname=$1
  username=$2
  server_type=$3
  mount_dir=$4
  local_dir=$5

  if [[ -z ${mount_dir} || -z ${local_dir} ]]; then
    mount_dir=/home/${username}
    local_dir=~/.mnt/${hostname}
  fi

  if [[ ${server_type} == "local" ]];then
    destination="${hostname}.local"
  else
    destination=${hostname}
  fi

  if [[ -d ${local_dir} ]]; then
    mntchk=$( df | grep -c ${local_dir} )
    if [[ ${mntchk} -eq 0 ]]; then
      result=0
      output=$(ping -i 0.2 -c 1 ${destination} 2>&1 > /dev/null) || result=$?
      if [[ ${result} -eq 0  || (( $+commands[sshfs] )) ]]; then
          sshfs -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${username}@${destination}:${mount_dir} ${local_dir}
      fi
    fi
  fi
}

# Usage
#  ( sshmount xxxx.com username server_type server_dir local_dir & )

#  for h in hostname1 hostname2
#  do
#    ( sshmount ${h} username server_type & )
#  done

# sshfs - unmount
function sshumount() {
  hostname=$1
  username=$2
  server_type=$3
  local_dir=$4

  if [[ -z ${local_dir} ]]; then
    local_dir=~/.mnt/${hostname}
  fi

  if [[ ${server_type} == "local" ]];then
    destination="${hostname}.local"
  else
    destination=${hostname}
  fi

  if [[ -d ${local_dir} ]]; then
    mntchk=$( df | grep -c ${local_dir} )
    if [[ ${mntchk} > 0 ]]; then
      result=0
      output=$(ping -i 0.2 -c 1 ${destination} 2>&1 > /dev/null) || result=$?
      if [[ ${result} -eq 0 ]]; then
          umount ${local_dir}
      fi
    fi
  fi
}

# Usage
#  sshumount xxxx.com username server_type ~/.mnt/sun_nginx &

#for h in hostname1 hostname2
#do
#  sshumount ${h} username server_type &
#done

weather() {
  if (( $+commands[curl] )); then
    curl wttr.in/$1
  fi
}
