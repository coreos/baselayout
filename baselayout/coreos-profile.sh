# /usr/share/baselayout/coreos-profile.sh

# Only print for interactive shells.
if [[ $- == *i* ]]; then
	if ! [ -f  /run/update-engine/coordinator.conf ]; then
		# No coordinator running
		echo -e "Update Strategy: \033[31mNo Reboots\033[39m"
	elif flock --nonblock --exclusive /run/update-engine/coordinator.conf --command /bin/true &>/dev/null; then
		# Coordinator ran, but isn't currently running
		echo -e "Update Strategy: \033[31mNo Reboots\033[39m"
	else
		# subshell to avoid env pollution
		(
			# Helper warn if disabled or rebooting soon
			warn() {
					echo -e "Update Status: \033[33m${NAME} - ${1}\033[39m"
			}
			source /run/update-engine/coordinator.conf
			case "${STATE}" in
				running|starting)
					;;
				disabled)
					warn "Updates disabled"
					;;
				rebooting|reboot-planned)
					warn "Reboot planned"
					;;
				*)
					warn "${STATE}"
					;;
			esac
		)
	fi

	FAILED=$(systemctl list-units --state=failed --no-legend)
	if [[ ! -z "${FAILED}" ]]; then
		COUNT=$(wc -l <<<"${FAILED}")
		echo -e "Failed Units: \033[31m${COUNT}\033[39m"
		awk '{ print "  " $1 }' <<<"${FAILED}"
	fi
fi
