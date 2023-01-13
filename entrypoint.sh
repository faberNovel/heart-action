#!/bin/bash

# generate_heart_command repositoryName analysisService file inline threshold
# Generate the heart command from the given arguments.
generate_heart_command() {
  local cliOptions=""

  if [ -n "$3" ]; then cliOptions+=" --file $1/$3"; fi
  if [ -n "$4" ]; then cliOptions+=" --inline $4"; fi
  if [ -n "$5" ]; then cliOptions+=" --threshold $5"; fi

  echo $2$cliOptions
}

# generate_installable_packages analysisService listenerServices
# Generate the list of packages names to install with the version indicator, separated by a space.
generate_installable_packages() {
  local packageNamePrefix="@fabernovel/heart-"
  local packageMajorVersionIndicator="@^3.0.0"
  local servicesToInstall="cli $1 "

  # add listener services
  if [ -n "$2" ]; then
    servicesToInstall+="${2//,/ }"
  fi

  servicesToInstall=$(echo $servicesToInstall | xargs)

  # build the package names from the services names (add the @fabernovel/heart- prefix)
  packagesToInstall=$packageNamePrefix${servicesToInstall// / $packageNamePrefix}

  # set packages version
  echo ${packagesToInstall// /$packageMajorVersionIndicator }$packageMajorVersionIndicator
}

# trim(string)
# Trim a string.
# see https://stackoverflow.com/a/3232433
trim() {
  echo "$(echo -e "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

# name of the directory in which the repository will be cloned.
# this will be used in git clone command below
repositoryName="repository"
# service name that analyze the URL (e.g. greenit)
analysisService=$(trim $1)
# file path to the JSON configuration used by the analysis service.
file=$(trim $2)
# inline string of the JSON configuration used by the analysis service.
inline=$(trim $3)
# check if the score of the result reaches the given threshold (between 0 and 100).
threshold=$(trim $4)
# services names that process the result of the analyze, separated by commas (e.g. slack,bigquery)
listenerServices=$(trim $5)

# if the file input has been been set, we need to have the file available for heart to read it.
# checks that the repository does not already exist too.
if [ -n "$file" ] && [[ ! -f $repositoryName ]]; then
  git clone "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY.git" --branch $GITHUB_REF_NAME $repositoryName
fi

# install dependencies
# create the package.json if it does not already exist, and hide the console output
if [[ ! -f "package.json" ]]; then npm init -y > /dev/null; fi
packages=$(generate_installable_packages "$analysisService" "$listenerServices")
npm install $packages

# run the heart command
npx heart $(generate_heart_command "$repositoryName" "$analysisService" "$file" "$inline" "$threshold")
