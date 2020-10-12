#!/bin/bash

#title           :checklist.sh
#description     :This script takes simple checklist of important system configurations.
#		 :it is meant to be run before and after server patching/reboot activity.
#		 :It helps sysadmins compare the configurations pre- and post-patching.
#		 :and thus rectify any unwanted changes made during the patching activity.
#date            :13022018
#version         :0.1
#usage           :bash checklist.sh
#bash_version    :4.2.46(2)-release (x86_64-redhat-linux-gnu)
#author          :Srinidhi Rao (srinidhirao.c@gmail.com)

#set -xv

HOST="$(hostname)"
CHKLST_FILE="/root/checklist_${HOST}_$(date +%Y%m%d_%H%M)"
#mkdir -p $CHKLST_DIR
#cd $CHKLST_DIR


#List of commands for EL6
declare -a CMDLIST_6=(
'hostname'
'hostname --fqdn'
'cat /etc/*-release'
'cat /etc/issue'
'cat /etc/sysconfig/network'
'date; uptime'
'ls -l /etc/localtime'
'curl -ss ifconfig.me'
'dmidecode -t1'
'lsmod'
'lspci'
'ls /etc/sysconfig/network-scripts/ifcfg-*'
'/sbin/ifconfig -a'
'grep -v ^"#" /etc/resolv.conf'
'cat /etc/hosts'
'route -n'
'netstat -tulpn'
'df -hPT'
'lsblk'
'cat /proc/mounts'
'fdisk -l'
'blkid'
'cat /etc/fstab'
'cat /etc/mtab'
'multipath -l'
'iscsiadm -m session'
'ls -lrth /dev/disk/by-path'
'cat /etc/cluster/cluster.conf'
'free'
'cat /proc/meminfo'
'cat /proc/cpuinfo'
'iptables -L -n'
'cat /etc/sysconfig/iptables'
'grep -v ^"#" /etc/hosts.deny'
'grep -v ^"#" /etc/hosts.allow'
'runlevel'
'service --status-all'
'chkconfig --list'
'chkconfig --list | grep 3:on'
'chkconfig --list | grep 5:on'
'ps auxww'
'grep -v ^"#" /etc/inittab'
'grep -v ^"#" /etc/rc.local'
'crontab -l'
'ls -l /var/spool/cron/'
'cat /var/spool/cron/*'
'grep -i "(error|warning)" /var/log/messages'
'ntpd --version'
'grep -v ^"#" /etc/ntp.conf'
)

#List of commands for EL7
declare -a CMDLIST_7=(
'hostnamectl'
'cat /etc/hostname'
'cat /etc/*-release'
'date; uptime'
'ls -l /etc/localtime'
'curl -ss ifconfig.me'
'dmidecode -t1'
'lsmod'
'lspci'
'ls /etc/sysconfig/network-scripts/ifcfg-*'
'nmcli device status'
'nmcli connection show'
'ip a'
'ip r l'
'grep -v ^"#" /etc/resolv.conf'
'cat /etc/hosts'
'route -n'
'netstat -tulpn'
'df -hPT'
'lsblk'
'cat /proc/mounts'
'fdisk -l'
'blkid'
'cat /etc/fstab'
'cat /etc/mtab'
'multipath -l'
'iscsiadm -m session'
'ls -lrth /dev/disk/by-path'
'cat /etc/cluster/cluster.conf'
'free'
'cat /proc/meminfo'
'cat /proc/cpuinfo'
'firewall-cmd --list-all'
'iptables -L -n'
'cat /etc/sysconfig/iptables'
'grep -v ^"#" /etc/hosts.deny'
'grep -v ^"#" /etc/hosts.allow'
'systemctl get-default'
'systemctl list-units --type=service'
'systemctl list-unit-files --type=service'
'ps auxww'
'grep -v ^"#" /etc/inittab'
'grep -v ^"#" /etc/rc.local'
'crontab -l'
'ls -l /var/spool/cron/'
'cat /var/spool/cron/*'
'grep -i "(error|warning)" /var/log/messages'
'ntpd --version'
'grep -v ^"#" /etc/ntp.conf'
)


basic_check() {
    # is the OS RPM based?
    if ! command -v rpm &> /dev/null; then
        echo "This script is meant to be run only on 'rpm' based OS."
        exit 1
    fi
}

get_os() {
    # what is the os version?
    # args: running_kernel - kernel string as returned by 'uname -r'
    # returns RHEL number/version

    local running_kernel="$1"
    local rhel=$( sed -r -n 's/^.*el([[:digit:]]).*$/\1/p' <<< "$running_kernel" )
    echo "$rhel"
}


function take_checklist() {
    # creates checklist of main configs
    # args: commandlist array

	CMDLIST=("$@")

	printf "\n=== Below is checklist of important configs of $HOST taken on $(date) ===\n\n" >> $CHKLST_FILE

	for (( i = 0; i < ${#CMDLIST[@]} ; i++ )); do
	    printf "\n== Output of command: ${CMDLIST[$i]} ==\n\n" >> $CHKLST_FILE
	    eval "${CMDLIST[$i]} 2>&1" >> $CHKLST_FILE
	    printf "\n============\n\n" >> $CHKLST_FILE
	done

	printf "\n Checklist has been collected in file: $CHKLST_FILE \n\n"
}



basic_check
running_kernel=$( uname -r )
rhel=$( get_os "$running_kernel" )

if (( rhel == 5 )); then
	echo "RHEL5/CentOS-5 are not supported."
        exit 1

elif (( rhel == 6 )); then
#        echo "RHEL6/CentOS6 are supported."
	take_checklist "${CMDLIST_6[@]}"
        exit 0

else
#	echo "RHEL7/CentOS7 are supported."
	take_checklist "${CMDLIST_7[@]}"
	exit 0
fi