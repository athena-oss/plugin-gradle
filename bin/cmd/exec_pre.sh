CMD_DESCRIPTION="Execute one or multiple gradle tasks."

athena.usage 1 "<project_dir> [<opts>...] [<tasks>...]" "$(cat <<EOF
   <project_dir>                             ; Directory where your gradle project is.
   [--list-java-versions]                    ; Retrieve list of available Java versions with use with --java-version option.
   [--java-version=<version>]                ; Java version to be used (e.g. 7, 8). By default will be set to 'latest'.
   [--skip-sync]                             ; On Mac OSX we rsync your project directory with a volume inside the container, to speed up things.
                                             ; Use this option to skip this behaviour and use directly your project directory.
   [--skip-gradlew]                          ; By default we use the 'gradlew' inside the project directory. Use this option to skip this behaviour.
   [--with-avd=<container_name>|<ip>:<port>] ; Container with the AVD, running in the host machine, or a remote AVD.
EOF
)"

if athena.arg_exists "--list-java-versions"; then
	athena.info "Available versions:"
	for version in $(athena.plugin.get_plg_docker_dir "$(athena.plugin.get_plg)")/java*; do
		athena.info "* $(basename ${version} | sed 's/^java-//g')"
	done
	athena.os.exit
fi

project_dir="$(athena.path 1)"
athena.pop_args 1

# check if the user wants to link with a device
if athena.arg_exists "--with-avd"; then
	connection_target="$(athena.argument.get_argument --with-avd)"
	athena.info "Discovering '${connection_target}'..."
	if athena.docker.is_container_running "$connection_target"; then
		athena.info "Linking with '${connection_target}' container..."
		athena.docker.add_option "--link ${connection_target}:${connection_target}"
	fi
fi

# try linking with appium and selenium hub
athena.plugins.gradle.try_to_auto_link_containers "appium" "athena-appium"
athena.plugins.gradle.try_to_auto_link_containers "hub" "athena-selenium-hub"

if ! athena.plugin.is_environment_specified; then
	athena.docker.volume_exists_or_create "athena_cache_android"
	athena.docker.add_option "-v athena_cache_android:/opt/android-sdk"
fi

# handle java version selection
java_version="openjdk-latest"
athena.argument.argument_exists_and_remove "--java-version" "java_version"
athena.plugin.use_container "java-${java_version}"

# In Mac OS we run gradle against a rsynced directory to avoid the bad performance
# of docker for mac OXFS
if athena.os.is_mac && ! athena.argument.argument_exists_and_remove "--skip-sync"; then
	athena.docker.add_env "ATHENA_SYNC_FROM_DIR" "/opt/project"
	athena.docker.mount_dir "$project_dir" "/opt/project"
	athena.docker.volume_exists_or_create "athena_cache_gradle_project"
	athena.docker.add_option "-v athena_cache_gradle_project:/opt/tests"
else
	athena.docker.mount_dir "$project_dir" "/opt/tests"
fi

# persistent cache volume for gradle packages
athena.docker.volume_exists_or_create "athena_cache_gradle_home"
athena.docker.add_option "-v athena_cache_gradle_home:/root/.gradle"
