ELIXIR_VERSION ?= 1.5
DOCKER_IMAGE = elixir:$(ELIXIR_VERSION)
DOCKER_CMD = docker run -ti --rm -v $(HOME)/.mix:/root/.mix -v $(PWD):/app --workdir /app $(DOCKER_IMAGE)
all:;: '$(ELIXIR_VERSION)'


.PHONY: test pull clean

pull:
	docker pull $(DOCKER_IMAGE)

$(HOME)/.mix/archives:
	$(DOCKER_CMD) mix local.hex --force

$(HOME)/.mix/rebar:
	$(DOCKER_CMD) mix local.rebar --force

deps: $(HOME)/.mix/archives $(HOME)/.mix/rebar mix.exs mix.lock
	$(DOCKER_CMD) mix deps.get

test: deps
	$(DOCKER_CMD) mix test

clean:
	$(DOCKER_CMD) sh -c 'rm -rf deps && rm -rf _build'
