# use a Node.js image with Chrome installed, because of @fabernovel/heart-greenit
FROM timbru31/node-chrome:14

# set environment variable to make the @fabernovel/heart-greenit module work
ENV CHROME_PATH=/usr/bin/google-chrome-stable

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
