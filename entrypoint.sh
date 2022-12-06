#!/bin/bash

# short name of the analysis module (e.g. greenit)
analysisModule=$1
# path to the JSON configuration file
file=$2
# inlined JSON configuration definition
inline=$3
# a threshold between 0 and 100 that you want to reach with the analysis
threshold=$4
# short names of the listener modules, separated by commas (e.g. slack,bigquery)
listenerModules=$5

generate_installable_modules() {
  local modulesShortnames="cli $analysisModule"
  local packageNamePrefix="@fabernovel/heart-"

  # add listener modules
  if [ -n "$listenerModules" ]; then
      modulesShortnames+=" ${listenerModules//,/ }"
  fi

  # add @fabernovel/heart- prefix to these values
  echo $packageNamePrefix${modulesShortnames// / $packageNamePrefix}
}

generate_heart_command() {
  local cliOptions=""

  if [ -n "$file" ]; then cliOptions+=" --file $file"; fi
  if [ -n "$inline" ]; then cliOptions+=" --inline $inline"; fi
  if [ -n "$threshold" ]; then cliOptions+=" --threshold $threshold"; fi

  echo $analysisModule$cliOptions
}

echo "Install modules"
npm init --yes
npm install $(generate_installable_modules)

echo "Running"
npx heart $(generate_heart_command)
