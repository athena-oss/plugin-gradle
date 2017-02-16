if athena.argument.argument_exists_and_remove "--with-avd" "connection_target"; then
	if ! hash adb 2>/dev/null; then
		athena.fatal "Android SDK platform-tools is not installed. Check documentation on how to build an environment for Android projects."
	fi
	athena.info "Connecting adb to ${connection_target} ..."
	if ! adb connect "$connection_target" 1>/dev/null; then
		athena.exit_with_msg "Failed to connect with $connection_target device..."
	fi
	athena.info "Waiting for connection to be established..."
	sleep 3
	athena.info "Tweaking device settings..."
	adb shell settings put global window_animation_scale 0
	adb shell settings put global transition_animation_scale 0
	adb shell settings put global animator_duration_scale 0
	athena.info "Waiting for device to be ready after the tweaks..."
	sleep 3
fi

if [[ ! -d "$PROJECT_DIR_IN_CONTAINER" ]]; then
	mkdir -p "$PROJECT_DIR_IN_CONTAINER"
fi

if [[ -n "$ATHENA_SYNC_FROM_DIR" ]]; then
	athena.info "Tests directory sync is active..."
	extra_opts=()
	if [[ -f "${ATHENA_SYNC_FROM_DIR}/.athenaignore" ]]; then
		athena.info "Found .athenaignore. Reading it..."
		extra_opts+=(--exclude-from "${ATHENA_SYNC_FROM_DIR}/.athenaignore")
	fi
	athena.info "Synching: [host] -> [container] ..."
	athena.debug "Synching: [host] '${ATHENA_SYNC_FROM_DIR}' -> [container] '${PROJECT_DIR_IN_CONTAINER}'..."
	rsync -a --info=progress2 "${extra_opts[@]}" "${ATHENA_SYNC_FROM_DIR}"/. "$PROJECT_DIR_IN_CONTAINER"
fi

cd "$PROJECT_DIR_IN_CONTAINER"

command=
if [[ -f ./gradlew ]] && ! athena.argument.argument_exists_and_remove "--skip-gradlew"; then
	command="./gradlew"
else
	command="gradle"
fi

arguments=()
athena.argument.get_arguments "arguments"

athena.info "Running command: $command ${arguments[*]}"
"$command" "${arguments[@]}"

if [[ -n "$ATHENA_SYNC_FROM_DIR" ]]; then
	athena.info "Tests directory sync is active..."
	extra_opts=()
	if [[ -f "${ATHENA_SYNC_FROM_DIR}/.athenaignore" ]]; then
		athena.info "Found .athenaignore. Reading it..."
		extra_opts+=(--exclude-from "${ATHENA_SYNC_FROM_DIR}/.athenaignore")
	fi

	athena.info "Synching: [container] -> [host] ..."
	athena.debug "Synching: [container] '${PROJECT_DIR_IN_CONTAINER}' -> [host] '${ATHENA_SYNC_FROM_DIR}'..."
	rsync -a --info=progress2 "${extra_opts[@]}" "$PROJECT_DIR_IN_CONTAINER"/* "$ATHENA_SYNC_FROM_DIR"
fi

