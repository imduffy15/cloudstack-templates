#! /bin/sh
### BEGIN INIT INFO
# Provides:          cloud-firstboot
# Required-Start:    $remote_fs $syslog $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Run at firstboot to set hypervisor specific settings. 
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin

. /lib/init/vars.sh
. /lib/lsb/init-functions

do_start() {
  [ "$VERBOSE" != no ] && log_begin_msg "Running cloud-firstboot"
  (sleep 60 && update-rc.d -f cloud-firstboot remove) &

  local hyp=$(hypervisor)
  case $hyp in
     xen-domU|xen-hvm)
          sed -i 's/^T0/#T0/' /etc/inittab && telinit q
          sed -i 's/^#vc/vc/' /etc/inittab && telinit q
          ;;
     kvm)
          sed -i 's/^#T0/T0/' /etc/inittab && telinit q
          sed -i 's/^vc/#vc/' /etc/inittab && telinit q
          ;;
     vmware)
          sed -i 's/^T0/#T0/' /etc/inittab && telinit q
          sed -i 's/^vc/#vc/' /etc/inittab && telinit q
          ;;
     virtualpc|hyperv)
          sed -i 's/^T0/#T0/' /etc/inittab && telinit q
          sed -i 's/^vc/#vc/' /etc/inittab && telinit q
          ;;
  esac
  
  ES=$?
  [ "$VERBOSE" != no ] && log_end_msg $ES
  return $ES
}


hypervisor() {
  [ -d /proc/xen ] && mount -t xenfs none /proc/xen
  [ -d /proc/xen ] && echo "xen-domU" && return 0

  local try=$([ -x /usr/sbin/virt-what ] && virt-what | tail -1)
  [ "$try" != "" ] && echo $try && return 0

  vmware-checkvm &> /dev/null && echo "vmware" && return 0

  grep -q QEMU /proc/cpuinfo  && echo "kvm" && return 0
  grep -q QEMU /var/log/messages && echo "kvm" && return 0

  echo "unknown" && return 1

}

case "$1" in
    start)
        do_start
        ;;
    restart|reload|force-reload)
        echo "Error: argument '$1' not supported" >&2
        exit 3
        ;;
    stop)
        ;;
    *)
        echo "Usage: $0 start|stop" >&2
        exit 3
        ;;
esac
