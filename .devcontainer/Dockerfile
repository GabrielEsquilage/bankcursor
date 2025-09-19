# Usa a imagem oficial do Elixir com OTP 25 e Elixir 1.14
FROM elixir:1.14-otp-25-alpine

# Instala as dependências do sistema usando o gerenciador de pacadores apk do Alpine
RUN apk update && apk add --no-cache \
    build-base \
    inotify-tools \
    curl \
    git \
    nodejs \
    npm \
    postgresql-client

# Define o diretório de trabalho
WORKDIR /workspace

# Instala as ferramentas do Elixir, Hex e Rebar
RUN mix local.hex --force && mix local.rebar --force

# Expõe a porta padrão do servidor Phoenix
EXPOSE 4000