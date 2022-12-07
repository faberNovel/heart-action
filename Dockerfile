# use a Node.js image with Chrome installed, because of @fabernovel/heart-greenit
FROM timbru31/node-chrome:14

# install packages that do not require an environment variable without default value (a secret for example).
# the reason is that Heart:^3.0.0 checks these first when the CLI is triggered, whatever the modules used in the CLI.
# for example, the Dareboost module is not installed here otherwise the environment variable for the API key
# will be checked before starting the analyze, even if the user wants do it with another analysis module.
RUN npm install

# set environment variable to make the @fabernovel/heart-greenit module work
ENV CHROME_PATH=/usr/bin/google-chrome-stable

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 