FROM fabernovel/heart:v4.0.1

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# As the --config option can be set to link to a file on the user's repository, we need git to retrieve it
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
    ca-certificates \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Creates a mount point where Heart has been installed to
VOLUME ["/usr/heart"]

# Use the working directory where Heart has been installed to
WORKDIR /usr/heart

COPY entrypoint.sh ./

ENTRYPOINT ["entrypoint.sh"]
