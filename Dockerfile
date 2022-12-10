# use a Node.js image with Chrome installed, because @fabernovel/heart-greenit requires Chrome installed.
# use latest Node.js LTS instead of Node.js 14 (which is the version supported by Heart) because of
# an unresolvable bug with node-gyp during installation with Node.js 14 / NPM 6.
FROM timbru31/node-chrome:18

# set environment variable to make the @fabernovel/heart-greenit module work
ENV CHROME_PATH=/usr/bin/google-chrome-stable

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 