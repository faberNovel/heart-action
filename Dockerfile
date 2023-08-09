FROM bgatellier/heart:1.0

# set bash as the default shell
SHELL ["/bin/bash", "-c"]

# As the config can be a file on the user's repository, we need git to retrieve it
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
    ca-certificates=20230311 \
    git=1:2.39.2-1.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
