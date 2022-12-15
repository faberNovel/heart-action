#!/bin/bash

# note: $(echo $1 | xargs) syntax is used to trim the $1 string
# see https://stackoverflow.com/a/12973694

# name of the directory in which the repository will be cloned.
# this will be used in git clone command below
repositoryName="repository"
# service name that analyze the URL (e.g. greenit)
analysisService=$(echo $1 | xargs)
# file path to the JSON configuration used by the analysis service.
file=$(echo $2 | xargs)
# inline string of the JSON configuration used by the analysis service.
inline=$(echo $3 | xargs)
# check if the score of the result reaches the given threshold (between 0 and 100).
threshold=$(echo $4 | xargs)
# services names that process the result of the analyze, separated by commas (e.g. slack,bigquery)
listenerServices=$(echo $5 | xargs)

generate_installable_packages() {
  local packageNamePrefix="@fabernovel/heart-"
  local packageMajorVersionIndicator="@^3.0.0"
  local servicesToInstall="cli $analysisService "

  # add listener services
  if [ -n "$listenerServices" ]; then
    servicesToInstall+="${listenerServices//,/ }"
  fi

  servicesToInstall=$(echo $servicesToInstall | xargs)

  # build the package names from the services names (add the @fabernovel/heart- prefix)
  packagesToInstall=$packageNamePrefix${servicesToInstall// / $packageNamePrefix}

  # set packages version
  echo ${packagesToInstall// /$packageMajorVersionIndicator }$packageMajorVersionIndicator
}

generate_heart_command() {
  local cliOptions=""

  if [ -n "$file" ]; then cliOptions+=" --file $repositoryName/$file"; fi
  if [ -n "$inline" ]; then cliOptions+=" --inline $inline"; fi
  if [ -n "$threshold" ]; then cliOptions+=" --threshold $threshold"; fi

  echo $analysisService$cliOptions
}
 
# if the file input has been been set, we need to have the file available for heart to read it.
# checks that the repository does not already exist too.
if [ -n "$file" ] && [[ ! -f $repositoryName ]]; then
  git clone "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY.git" --branch $GITHUB_REF_NAME $repositoryName
fi

# install dependencies
# create the package.json if it does not already exist, and hide the console output
if [[ ! -f "package.json" ]]; then npm init -y > /dev/null; fi
packages=$(generate_installable_packages)
npm install $packages

# run the heart command
echo "npx heart $(generate_heart_command)"
npx heart $(generate_heart_command)
