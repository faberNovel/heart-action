#!/bin/bash

# service name that analyze the URL (e.g. greenit).
analysisService=$1
# file path to the JSON configuration used by the analysis service.
file=$2
# inline string of the JSON configuration used by the analysis service.
inline=$3
# check if the score of the result reaches the given threshold (between 0 and 100).
threshold=$4
# services names that process the result of the analyze, separated by commas (e.g. slack,bigquery)
listenerServices=$5

generate_installable_modules() {
  local servicesNames="cli $analysisService"
  local packageNamePrefix="@fabernovel/heart-"
  local packageMajorVersionIndicator="@^3.0.0"

  # add listener services
  if [ -n "$listenerServices" ]; then
      servicesNames+=" ${listenerServices//,/ }"
  fi

  # build the package names from the services names (add the @fabernovel/heart- prefix)
  packagesNames=$packageNamePrefix${servicesNames// / $packageNamePrefix}
  # fix packages version
  echo ${packagesNames// /$packageMajorVersionIndicator }$packageMajorVersionIndicator
}

generate_heart_command() {
  local cliOptions=""

  if [ -n "$file" ]; then cliOptions+=" --file $file"; fi
  if [ -n "$inline" ]; then cliOptions+=" --inline $inline"; fi
  if [ -n "$threshold" ]; then cliOptions+=" --threshold $threshold"; fi

  echo $analysisService$cliOptions
}

npm init --yes > /dev/null
npm install $(generate_installable_modules)
npx heart $(generate_heart_command)
