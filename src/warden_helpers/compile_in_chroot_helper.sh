function disable {
  mv $1 $1.back
  ln -s /bin/true $1

}

function enable {
  if [ -L $1 ]
  then
    mv $1.back $1
  else
    # No longer a symbolic link, must have been overwritten
    rm -f $1.back
  fi

}

function compile_in_chroot {
  local chroot=$1
  local script=$2

  # Disable daemon startup
  disable $chroot/sbin/initctl
  disable $chroot/usr/sbin/invoke-rc.d


  unshare -m $SHELL <<EOS
    mkdir -p $chroot/dev
    mount -n --bind /dev $chroot/dev

    for package_dir in \$(ls -d /var/vcap/packages/*/ | grep -v $chroot); do
      mkdir -p $chroot/\$package_dir
      mount -n --bind \$(readlink -nf \$package_dir) $chroot/\$package_dir
    done

    mkdir -p $chroot/$BOSH_COMPILE_TARGET
    mount -n --bind $BOSH_COMPILE_TARGET $chroot/$BOSH_COMPILE_TARGET

    mount -n --bind /dev/pts $chroot/dev/pts
    mkdir -p $chroot/proc
    mount -n -t proc proc $chroot/proc
    chroot $chroot env -i $(cat $chroot/etc/environment) http_proxy=${http_proxy:-} bash -e -c "$script"
EOS

  # Enable daemon startup
  enable $chroot/sbin/initctl
  enable $chroot/usr/sbin/invoke-rc.d

}
