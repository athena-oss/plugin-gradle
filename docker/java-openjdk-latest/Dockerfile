FROM openjdk:latest

# build arguments
ARG GRADLE_VERSION="3.1"
ARG ANDROID_SDK_URL=""
ARG ANDROID_DEPENDENCIES=""

# default environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:/home/gradle/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# required utilities
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y wget unzip rsync && \
	apt-get autoremove && \
	apt-get clean && \
	rm -rf /var/apt/lists/* /var/tmp/* /tmp/*

# Download Android SDK
RUN if [ -n "$ANDROID_SDK_URL" ]; then \
		mkdir -p ${ANDROID_HOME}/licenses; \
		echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"; \
		echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "${ANDROID_HOME}/licenses/android-sdk-preview-license"; \
		wget -qO- "$ANDROID_SDK_URL" | tar --strip-components 1 -zx -C "$ANDROID_HOME"; \
		echo y | android update sdk --no-ui --all --filter platform-tools,$ANDROID_DEPENDENCIES --force; \
	fi

# Install Gradle
RUN wget https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /home/gradle.zip && \
	unzip /home/gradle.zip -d /home/ && \
	mv /home/gradle-${GRADLE_VERSION} /home/gradle && rm /home/gradle.zip
