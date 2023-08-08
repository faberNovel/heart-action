FROM bgatellier/heart:1.0

# As the config can be a file on the user's repository, we need git to retrieve it
RUN apt-get -yq install git

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 