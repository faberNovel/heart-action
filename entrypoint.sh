#!/bin/bash

# generate_heart_command analysisService config threshold except-listeners only-listeners verbose
# Generate the heart command from the given arguments.
generate_heart_command() {
  local cliOptions="$1 --config $2"

  if [ -n "$3" ]; then cliOptions+=" --threshold $3"; fi
  if [ -n "$4" ]; then cliOptions+=" --except-listeners $4"; fi
  if [ -n "$5" ]; then cliOptions+=" --only-listeners $5"; fi
  if [ -n "$6" ]; then cliOptions+=" --verbose"; fi

  echo $cliOptions
}

# trim(string)
# Trim a string.
# see https://stackoverflow.com/a/3232433
trim() {
  echo "$(echo -e "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

echo "$1"
echo "$2"
echo "$3"
echo "$4"
echo "$5"
echo "$6"

# service name that analyze the URL (e.g. greenit)
analysisService=$(trim $1)
# file path or inline string to the JSON configuration used by the analysis service.
config=$(trim $2)
# check if the score of the result reaches the given threshold (between 0 and 100).
threshold=$(trim $3)
# services names that process the result of the analyze, separated by commas (e.g. slack,bigquery)
exceptServices=$(trim $4)
onlyServices=$(trim $5)
verbose=$(trim $6)

echo "analysisService: $analysisService"
echo "config: $config"
echo "threshold: $threshold"
echo "exceptServices: $exceptServices"
echo "onlyServices: $onlyServices"
echo "verbose: $verbose"

echo "$GITHUB_WORKSPACE/$config"
if [[ -f "$GITHUB_WORKSPACE/$config" ]]; then
  config="$GITHUB_WORKSPACE/$config"
fi

# navigate to the working directory where Heart has been installed to
# note: do not use the Dockerfile WORKDIR command, as explained in the documentation:
# https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#workdir
cd /usr/heart

# run the heart command
command=$(generate_heart_command "$analysisService" "$config" "$threshold" "$exceptServices" "$onlyServices" "$verbose")
echo $command
npx heart $command
