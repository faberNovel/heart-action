#!/bin/bash

# note: $(echo $1 | xargs) syntax is used to trim the $1 string
# see https://stackoverflow.com/a/12973694

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

generate_installable_modules() {
  # services already installed (see package.json and Dockerfile)
  local servicesAlreadyInstalled="greenit lighthouse observatory ssllabs-server"
  local servicesToInstall=""

  # add analysis services
  if [[ $alreadyInstalledService != *"$analysisService"* ]]; then
    servicesToInstall+="$analysisService "
  fi

  # add listener services
  if [ -n "$listenerServices" ]; then
    servicesToInstall+="${listenerServices//,/ }"
  fi

  servicesToInstall=$(echo $servicesToInstall | xargs)

  if [ -z "$servicesToInstall" ]; then
    echo ""
  else
    local packageNamePrefix="@fabernovel/heart-"
    local packageMajorVersionIndicator="@^3.0.0"

    # build the package names from the services names (add the @fabernovel/heart- prefix)
    packagesToInstall=$packageNamePrefix${servicesToInstall// / $packageNamePrefix}

    # set packages version
    echo ${packagesToInstall// /$packageMajorVersionIndicator }$packageMajorVersionIndicator
  fi
}

generate_heart_command() {
  local cliOptions=""

  if [ -n "$file" ]; then cliOptions+=" --file $file"; fi
  if [ -n "$inline" ]; then cliOptions+=" --inline $inline"; fi
  if [ -n "$threshold" ]; then cliOptions+=" --threshold $threshold"; fi

  echo $analysisService$cliOptions
}

# install dependencies
installableModules=$(generate_installable_modules)
if [ -n "$installableModules" ]; then
  npm install $installableModules
fi

# run the heart command
npx heart $(generate_heart_command)
