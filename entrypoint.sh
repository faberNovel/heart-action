#!/bin/bash

# generate_heart_command analysisService config threshold except-listeners only-listeners verbose
# Generate the heart command from the given arguments.
generate_heart_command() {
  local cliOptions=" --config $2"

  if [ -n "$3" ]; then cliOptions+=" --threshold $3"; fi
  if [ -n "$4" ]; then cliOptions+=" --except-listeners $4"; fi
  if [ -n "$5" ]; then cliOptions+=" --only-listeners $5"; fi
  if [ -n "$6" ]; then cliOptions+=" --verbose"; fi

  echo $1$cliOptions
}

# trim(string)
# Trim a string.
# see https://stackoverflow.com/a/3232433
trim() {
  echo "$(echo -e "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}

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

# clone the repository, because we need the configuration file if the provided config is a file.
# checks that the repository does not already exist too.
git clone "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY.git" --branch $GITHUB_REF_NAME

# run the heart command
command=$(generate_heart_command "$analysisService" "$config" "$threshold" "$exceptServices" "$onlyServices" "$verbose")
npx heart $command
