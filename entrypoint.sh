#!/bin/bash

# service name that analyze the URL (e.g. greenit)
analysisService=$1
# path to the JSON configuration file
file=$2
# inlined JSON configuration definition
inline=$3
# a threshold between 0 and 100 that you want to reach with the analysis
threshold=$4
# services names that process the result of the analyze, separated by commas (e.g. slack,bigquery)
listenerServices=$5

generate_installable_modules() {
  local servicesNames="cli $analysisService"
  local packageNamePrefix="@fabernovel/heart-"

  # add listener services
  if [ -n "$listenerServices" ]; then
      servicesNames+=" ${listenerServices//,/ }"
  fi

  # build the package names from the services names (add the @fabernovel/heart- prefix)
  echo $packageNamePrefix${servicesNames// / $packageNamePrefix}
}

generate_heart_command() {
  local cliOptions=""

  if [ -n "$file" ]; then cliOptions+=" --file $file"; fi
  if [ -n "$inline" ]; then cliOptions+=" --inline $inline"; fi
  if [ -n "$threshold" ]; then cliOptions+=" --threshold $threshold"; fi

  echo $analysisService$cliOptions
}

npm init --yes
npm install $(generate_installable_modules)
npx heart $(generate_heart_command)
