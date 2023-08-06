FROM bgatellier/heart:1.0

# Uncomment the next 2 lines for local development
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# set bash as the default shell
SHELL ["/bin/bash", "-c"]
 