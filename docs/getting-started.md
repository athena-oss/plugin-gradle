# Change Java Version

To switch Java versions is pretty straight forward:

```
$ # get a list of supported versions
$ athena gradle exec --list-java-versions

$ # execute your task
$ athena gradle exec my-project/ test --java-version=oracle-8jdk
```

# Configure the Environment

The container where your gradle project runs is configurable; specify a environment file using `--athena-env=<file_path>` with custom settings.

One of the situations where you would have a custom environment: Android project.

An example of a environment file:
```
GRADLE_VERSION=3.1
ANDROID_SDK_URL=http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
ANDROID_DEPENDENCIES=extra-android-support,extra-google-support,extra-google-google_play_services,extra-google-m2repository,extra-android-m2repository
```

This assures you have everything you need for your Android project.

**NOTE:** If your gradle build file already solves the SDK dependencies, you won't need to specify `ANDROID_DEPENDENCIES`.
