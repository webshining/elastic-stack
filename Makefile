ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: bootstrap

bootstrap:
	docker compose up bootstrap
rebuild:
	docker compose up -d --no-deps --force-recreate --build ${ARGS}