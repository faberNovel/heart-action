# Guide: Dockerizing a Node.js web app
# https://nodejs.org/en/docs/guides/nodejs-docker-webapp
FROM node:18

# Install Google Chrome dependencies.
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-doesnt-launch-on-linux
RUN apt-get update && \
    apt-get -yq install ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils

# Create app directory
WORKDIR /usr/heart

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
COPY entrypoint.sh /entrypoint.sh

# Install Heart dependencies.
# npm ci provide faster, reliable, reproducible builds for production environments.
RUN npm ci --omit=dev

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 