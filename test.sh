echo -e "\nKiem tra cau hinh LLDP cua server:" 
if [ -f /sys/class/dmi/id/sys_vendor ] && grep -qi "VMware" /sys/class/dmi/id/sys_vendor; then
	echo -e "Server Vmware khong can cai dat LLDP ==> OK" 
else
    lldp_package_check=$(rpm -qa | grep ^lldpd-)
    if [[ -n $lldp_package_check ]]; then
        echo -e "Server vat ly da cai lldp package ==> OK" 
			lldp_neighbors_check=$(lldpcli show neighbors | grep "LLDP neighbors:")
				if [[ -n $lldp_neighbors_check ]]; then
					echo -e "LLDP show neighbors ==> OK" 
				else
					echo -e "LLDP show neighbors ==> WARNING" 
				fi
    else
        echo -e "Server vat ly chua cai lldp package ==> WARNING" 
    fi
fi
