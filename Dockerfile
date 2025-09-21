# Build stage
FROM elixir:1.14-otp-25-alpine AS build

# Install build dependencies
RUN apk update && apk add --no-cache build-base nodejs

# Set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy dependency definition files
COPY mix.exs mix.lock ./

# Fetch dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy the rest of the application code
COPY . .

# Compile assets
RUN mix assets.deploy

# Build the release
RUN mix release

# Release stage
FROM alpine:latest AS app

# Install runtime dependencies
RUN apk update && apk add --no-cache postgresql-client

# Set the working directory
WORKDIR /app

# Copy the compiled release from the build stage
COPY --from=build /app/_build/prod/rel/bankcursor .

# Expose the application port
EXPOSE 4000

# Define the command to run the application
CMD ["bin/server"]
