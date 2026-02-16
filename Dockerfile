# Use the official Elixir image
FROM elixir:1.12

# Set the working directory
WORKDIR /app

# Copy the mix files
COPY mix.exs mix.lock ./

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install dependencies
COPY . .
RUN mix deps.get

# Set environment variables
ENV MIX_ENV=prod

# Compile the project
RUN mix compile

# Build the release
RUN mix release

# Expose the port
EXPOSE 4000

# Start the application
CMD ["_build/prod/rel/bankcursor/bin/bankcursor", "start"]