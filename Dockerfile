FROM fabernovel/heart:v4.0.1

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Creates a mount point where Heart has been installed to
VOLUME ["/usr/heart"]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
