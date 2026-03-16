# Defines the development environment for the Phoenix application.

# Use the official Elixir image as the base.
# The version is pinned to ensure consistency across environments.
FROM elixir:1.14-otp-25-alpine

# Install essential packages required for the application and its dependencies.
# - build-base: for compiling native extensions.
# - git: for fetching git dependencies.
# - inotify-tools: for live-reloading in development.
RUN apk add --no-cache build-base git inotify-tools postgresql-client

# Set the working directory for the application.
WORKDIR /app

# Install Hex and Rebar, the package managers for Elixir.
RUN mix local.hex --force && mix local.rebar --force

# Copy the dependency definitions.
COPY mix.exs mix.lock ./

# Fetch all dependencies.
RUN mix deps.get

# Copy the application code.
# This is useful for building the image independently of docker-compose.
# When used with docker-compose, the local directory is mounted as a volume,
# overriding the contents of this directory.
COPY . .