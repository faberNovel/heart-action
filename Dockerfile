# use a Node.js image with Chrome installed, because @fabernovel/heart-greenit requires Chrome installed.
# use latest Node.js LTS instead of Node.js 14 (which is the version supported by Heart) because of
# an unresolvable bug with node-gyp during installation with Node.js 14 / NPM 6.
FROM node:18

# set environment variable to make the @fabernovel/heart-greenit module work
# ENV CHROME_PATH=/usr/bin/google-chrome-stable
# https://github.com/puppeteer/puppeteer/issues/290#issuecomment-322838700
RUN apt-get update && \
    apt-get -yq install gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 