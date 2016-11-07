if athena.argument.argument_exists_and_remove "--with-avd" "connection_target"; then
	if ! hash adb 2>/dev/null; then
		athena.fatal "Android SDK platform-tools is not installed. Check documentation on how to build an environment for Android projects."
	fi
	athena.info "Connecting adb to ${connection_target} ..."
	if ! adb connect "$connection_target" 1>/dev/null; then
		athena.exit_with_msg "Failed to connect with $connection_target device..."
	fi
	athena.info "Tweaking device settings..."
	adb shell settings put global window_animation_scale 0
	adb shell settings put global transition_animation_scale 0
	adb shell settings put global animator_duration_scale 0
	sleep 3
fi

if [[ -n "$ATHENA_SYNC_FROM_DIR" ]]; then
	athena.info "Synchronizing cached project dir..."
	extra_opts=
	if [[ -f "${ATHENA_SYNC_FROM_DIR}/.athenaignore" ]]; then
		extra_opts="--exclude-from ${ATHENA_SYNC_FROM_DIR}/.athenaignore"
	fi
	rsync -a --info=progress2 $extra_opts ${ATHENA_SYNC_FROM_DIR}/* /opt/tests
fi

cd /opt/tests

command=
if [[ -f ./gradlew ]] && ! athena.argument.argument_exists_and_remove "--skip-gradlew"; then
	command="./gradlew"
else
	command="gradle"
fi

athena.info "Running command: $command $(athena.args)"
$command $(athena.args)
