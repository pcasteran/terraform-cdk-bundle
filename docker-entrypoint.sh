#!/bin/sh

set -e

# Create the HOME directory if it does not exists.
if [ ! -d "${HOME}" ]; then
  echo "Creating the HOME directory (${HOME})..."
  mkdir -p "${HOME}"
  echo "**" > "${HOME}"/.gitignore
fi

# Execute the specified command.
exec "$@"
