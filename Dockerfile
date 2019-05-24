FROM elixir:1.8
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.* /app/
RUN mix do deps.get deps.compile
