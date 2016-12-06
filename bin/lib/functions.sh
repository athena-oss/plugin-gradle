function athena.plugins.gradle.try_to_auto_link_containers()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "type"
	athena.argument.argument_is_not_empty_or_fail "$2" "link_name"
	local type="$1"
	local link_name="$2"

	if athena.argument.argument_exists_and_remove "--skip-${type}"; then
		athena.color.print_info "Skipping auto link with ${type}..."
		return 1
	fi

	container_name=
	if athena.argument.argument_exists "--link-${type}"; then
		athena.argument.get_argument_and_remove "--link-${type}" "container_name"

		if ! athena.docker.is_container_running "$container_name"; then
			athena.os.exit_with_msg "Failed to auto link with ${type} '${container_name}'. Container is not running.."
		fi
	else
		case "$type" in
		appium )
			if [[ ! -d "$(athena.plugin.get_plugins_dir)/appium" ]]; then
				athena.color.print_debug "Skipped auto link with Appium. Plugin is not installed..."
				return 1
			fi

			old_plg="$(athena.plugin.get_plg)"
			athena.plugin.require "appium" "0.3.0"
			athena.plugin.set_plugin "appium"
			container_name=$(athena.plugin.get_container_name)
			athena.plugin.set_plugin "$old_plg"
			;;
		hub )
			if [[ ! -d "$(athena.plugin.get_plugins_dir)/selenium" ]]; then
				athena.color.print_debug "Skipped auto link with Selenium. Plugin is not installed..."
				return 1
			fi

			athena.plugin.require "selenium" "0.3.1"
			container_name="$(athena.plugins.selenium.get_container_name $type)"
			;;
		esac

		if ! athena.docker.is_container_running "$container_name"; then
			athena.color.print_debug "Skipped auto link with ${type} '${container_name}'. Container is not running."
			return 1
		fi
	fi

	athena.color.print_info "Auto linking with $type container '${container_name}'..."
	athena.docker.add_option "--link ${container_name}:${link_name}"
}
