#!/bin/bash
#
# script to change de hostnames in .yml files for:
#	* cloud_controller
#	* mbus
#	* router
# It could be executed before o after the installation.
# It's very important that the host names can to be translated into ip address
# either by DNS or /etc/hosts.
#

usage () {
cat << EOF
usage: $0 options

OPTIONS:
  -h           Show this message
  -c hostname  Set cloud_controller hostname in .yml archives
  -m hostname  Set mbus ( mbus: nats:// ) hostname in .yml archives
  -r hostname  Set router ( local_route: ) ip in .yml archives

EOF
}

apply_changes () {
	set -x
	# ----------------------
	# List of files to chage
	# ----------------------
	LISTA=/tmp/lista.${OPTARG}
	grep -rn ${SEARCH} * | grep .yml: | awk -F':' '{print $1}' | sort | uniq > ${LISTA}

	# --------------------------
	# Replace PATTER with OPTARG
	# --------------------------
	for FILE in $(cat ${LISTA});do
		cp ${FILE} ${FILE}.$(date +%Y%m%d%H%M%S)
		sed -i "s/${PATTERN}/${OPTARG}/g" ${FILE}
	done
	set +x
}

[ $# -lt 1 ] && usage

pushd ~/cloudfoundry/vcap 2>&1 >> /dev/null

while getopts "hc:m:r:" OPTION;do

# --------------------------------------
# SEARCH: string to use in grep command
# PATTERN: string to use in sed command
# -------------------------------------

	case $OPTION in
		h)
			usage
			exit 1
			;;
		c)
			echo "Changing cloud_controller hostname" 
			SEARCH=api.vcap.me
			PATTERN=api.vcap.me
			apply_changes
			;;
		m)
			echo "Changing mbus ( nats:// ) hostname"
			SEARCH=nats://localhost:4222
			PATTERN=localhost
			apply_changes
			;;
		r)
			echo "Changing router ( local_route: ) ip hostname"
			SEARCH=local_route:
			PATTERN=127.0.0.1
			apply_changes
			;;
		*)
			usage
			exit 1
			;;
	esac
	

done

popd 2>&1 >> /dev/null

#vim: set ts=4 :
