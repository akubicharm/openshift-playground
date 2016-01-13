# Kickstart for provisioning a RHEL 7 Azure VM

# System authorization information
auth --enableshadow --passalgo=sha512

# Use graphical install
text

# Do not run the Setup Agent on first boot
firstboot --disable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp

# Root password
rootpw --plaintext "to_be_disabled"

# System services
services --enabled="sshd,waagent,NetworkManager"

# System timezone
timezone Etc/UTC --isUtc --ntpservers 0.rhel.pool.ntp.org,1.rhel.pool.ntp.org,2.rhel.pool.ntp.org,3.rhel.pool.ntp.org

# Partition clearing information
clearpart --all --initlabel

# Clear the MBR
zerombr

# Disk partitioning information
part /boot --fstype="xfs" --size=500
part / --fstyp="xfs" --size=1 --grow --asprimary

# System bootloader configuration
bootloader --location=mbr

# Firewall configuration
firewall --disabled

# Enable SELinux
selinux --enforcing

# Don't configure X
skipx

# Power down the machine after install
poweroff

# Primary Fedora repo
repo --name="epel7" --baseurl="http://dl.fedoraproject.org/pub/epel/7/x86_64/"

%packages
@base
@console-internet
chrony
sudo
python-pyasn1
parted
ntfsprogs
WALinuxAgent
-dracut-config-rescue

%end

%post --log=/var/log/anaconda/post-install.log

#!/bin/bash

# Disable the root account
usermod root -p '!!'

# Configure swap in WALinuxAgent
sed -i 's/^\(ResourceDisk\.EnableSwap\)=[Nn]$/\1=y/g' /etc/waagent.conf
sed -i 's/^\(ResourceDisk\.SwapSizeMB\)=[0-9]*$/\1=2048/g' /etc/waagent.conf

# Set the cmdline
sed -i 's/^\(GRUB_CMDLINE_LINUX\)=".*"$/\1="console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300"/g' /etc/default/grub

# Enable SSH keepalive
sed -i 's/^#\(ClientAliveInterval\).*$/\1 180/g' /etc/ssh/sshd_config

# Build the grub cfg
grub2-mkconfig -o /boot/grub2/grub.cfg

# Configure network
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
NM_CONTROLLED=yes
EOF

# Deprovision and prepare for Azure
waagent -force -deprovision

%end
