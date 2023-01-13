# use a Node.js image with Chrome installed, because @fabernovel/heart-lighthouse requires an external Chrome installation.
# use the latest Node.js LTS instead of Node.js 14 (which is the version supported by Heart) because of
# an unresolvable bug with node-gyp during installation with Node.js 14 / NPM 6.
FROM timbru31/node-chrome:18

# weird missing library with @fabernovel/heart-greenit (maybe because of an outdated Chromium version):
# Error: Failed to launch the browser process!
# /node_modules/puppeteer/.local-chromium/linux-818858/chrome-linux/chrome: error while loading shared libraries: libX11-xcb.so.1: cannot open shared object file: No such file or directory
RUN apt-get update && \
    apt-get -yq install libx11-xcb1

# set environment variable to make the @fabernovel/heart-lighthouse module work
ENV CHROME_PATH=/usr/bin/google-chrome-stable

# lighter setup that could only work when @fabernovel/heart-lighthouse will rely on an "internal" browser (probably v4).
# by using pupeeter/chromium like @fabernovel/heart-greenit already does, there will be no need to install an external version of Chrome.
#
# FROM node:18
#
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-unix
# RUN apt-get update && \
#     apt-get -yq install ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils

# Uncomment the next 2 lines for local development
# WORKDIR /usr/app
# COPY ./ /usr/app
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 