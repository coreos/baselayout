# /usr/share/baselayout/coreos-profile.sh

# Only print for interactive shells.
if [[ $- == *i* ]]; then
	if ! systemctl is-active locksmithd > /dev/null; then
		echo -e "Update Strategy: \033[31mNo Reboots\033[39m"
	fi

	FAILED=$(systemctl list-units --state=failed --no-legend)
	if [[ ! -z "${FAILED}" ]]; then
		COUNT=$(wc -l <<<"${FAILED}")
		echo -e "Failed Units: \033[31m${COUNT}\033[39m"
		awk '{ print "  " $1 }' <<<"${FAILED}"
	fi
fi
