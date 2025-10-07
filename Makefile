include .env
.PHONY: enter-shell-php enter-shell-db enter-shell-front enter-shell-web-server enter-shell-redis \
        project-start project-stop project-down project-show-logs project-clean app-install app-security-check \
        app-back-cache-rebuild app-back-migrate app-back-data-setup app-back-install \
        app-back-composer-check app-back-security-check app-back-test-unit app-back-static-analysis \
        app-back-cs-check app-back-cs-fix app-front-install app-front-build app-front-run app-front-security-check app-front-lint \
        app-front-format app-front-format-fix app-front-test-unit ci-back-data-setup ci-back-test ci-back-data-setup \
        db\:dump db\:import


yellow = \033[38;5;3m
bold = \033[1m
reset = \033[0m
message = @echo -p "${yellow}${bold}${1}${reset}"

EXTRA_PARAMS ?=
UID = $(shell id -u)

#
# Executes a command in a running container, mainly useful to fix the terminal size on opening a shell session
#
# $(1) the options
#
define enter-shell
	docker-compose exec -e COLUMNS=`tput cols` -e LINES=`tput lines` $(1)
endef

#
# Make sure to run the given command in a container identified by the given service.
#
# $(1) the user with which run the command
# $(2) the Docker Compose service
# $(3) the command to run
#
define run-in-container
	@if [ ! -f /.dockerenv -a "$$(docker-compose ps -q $(2) 2>/dev/null)" ]; then \
		docker-compose exec --user $(1) $(2) /bin/sh -c "$(3)"; \
	elif [ $$(env|grep -c "^CI=") -gt 0 -a $$(env|grep -cw "DOCKER_DRIVER") -eq 1 ]; then \
		docker-compose exec --user $(1) -T $(2) /bin/sh -c "$(3)"; \
	else \
		$(3); \
	fi
endef

########################################
#              SETUP                   #
########################################

enter-shell-php: ## to open a shell session in the PHP container
	$(call enter-shell,-u root php bash)

enter-shell-db: ## to open a shell session in the database container
	$(call enter-shell,database bash)

enter-shell-front: ## to open a shell session in the Front end container
	$(call enter-shell,nodejs sh)

enter-shell-web-server: ## to open a shell session in the nginx container
	$(call enter-shell,nginx sh)

enter-shell-redis: ## to open a shell session in the Redis container
	$(call enter-shell,redis sh)

project-start: ## to start the containers
	$(call message,$(PROJECT_NAME): Starting Docker containers...)
	docker-compose up --build -d

project-stop: ## to stop the containers
	$(call message,$(PROJECT_NAME): Stopping Docker containers...)
	docker-compose stop

project-down: ## to remove the containers
	$(call message,$(PROJECT_NAME): Removing Docker network & containers...)
	docker-compose down -v --remove-orphans

project-show-logs: ## to show logs from containers, specify "EXTRA_PARAMS=service_name" to filter logs by container
	docker-compose logs -ft ${EXTRA_PARAMS}

project-clean: ## to remove the docker image
	$(call message,$(PROJECT_NAME): Removing Docker containers & Images...)
	@$(MAKE) -s project-down
	rm -Rvf dockerdb/*
	docker rmi ${PROJECT_NAME}_nginx ${PROJECT_NAME}_php ${PROJECT_NAME}_nodejs ${PROJECT_NAME}_database ${PROJECT_NAME}_redis

app-install: ## to install app
	$(MAKE) app-back-install
	$(MAKE) app-front-install
	$(MAKE) app-front-build

app-security-check: ## to run security check
	$(MAKE) app-back-security-check
	$(MAKE) app-front-security-check

########################
# App Backend #
########################

app-back-cache-rebuild: ## to rebuild the back end cache
	$(call message,$(PROJECT_NAME): Clearing Back end cache...)
	$(call run-in-container,www-data,php,php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan event:clear)

app-back-migrate: ## to run migration
	$(call message,$(PROJECT_NAME): Starting Migration...)
	$(call run-in-container,www-data,php,php artisan migrate)

app-back-data-setup: ## to clean up back end and import fresh db
	$(call message,$(PROJECT_NAME): Installing Back end...)
	@$(MAKE) -s app-back-install
	@$(MAKE) -s db\:import
	@$(MAKE) -s app-back-cache-rebuild
	$(call message,$(PROJECT_NAME): Back end is ready! $(BACKEND_URL))

app-back-install: ## to install back end
	$(call message,$(PROJECT_NAME): Installing/updating Back end dependencies...)
	$(call run-in-container,www-data,php,composer install --prefer-dist)
	$(call message,$(PROJECT_NAME): Back end is ready! $(BACKEND_URL))

app-back-composer-check: ## to validate composer config
	$(call run-in-container,www-data,php,composer validate --no-check-all)
	$(call run-in-container,www-data,php,composer normalize --dry-run)

app-back-security-check: ## to check security issues in the PHP dependencies
	$(call message,$(PROJECT_NAME): Checking Back end...)
	$(call run-in-container,www-data,php,vendor/bin/security-checker security:check)

app-back-test-unit: ## to run phpunit test
	$(call message,$(PROJECT_NAME): Start Testing...)
	$(call run-in-container,www-data,php,php artisan test)
	$(call message,$(PROJECT_NAME): Test Completed...)

app-back-test-behat: ## to run behat test
	$(call message,$(PROJECT_NAME): Start Testing...)
	$(call run-in-container,www-data,php,vendor/bin/behat --strict --no-interaction)
	$(call message,$(PROJECT_NAME): Test Completed...)

app-back-static-analysis: ## to run phpstan
	$(call message,$(PROJECT_NAME): Analysing the code...)
	$(call run-in-container,root,php,vendor/bin/phpstan analyze --memory-limit=-1)
	$(call message,$(PROJECT_NAME): Test Completed...)

app-back-cs-check: ## to check errors
	$(call run-in-container,www-data,php,vendor/bin/pint --test)

app-back-cs-fix: ## to fix errors
	$(call run-in-container,www-data,php,vendor/bin/pint)

########################
# App Front end #
########################

app-front-install: ## to install front end
	$(call message,$(PROJECT_NAME): Installing/updating Front end dependencies...)
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn cache clean --all && yarn)
	$(call message,$(PROJECT_NAME): Front end is ready!)

app-front-build: ## to build front end
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn build $(EXTRA_PARAMS))

app-front-run: ## to run front end
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn dev)

app-front-security-check: ## to check security issues in the node dependencies
	$(call message,$(PROJECT_NAME): Checking Front end...)
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn audit)

app-front-lint: ## to lint the front end app
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn lint)

app-front-format-fix: ## to test the front end app
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn format:fix)

app-front-format: ## to test the front end app
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn format)

app-front-test-unit:
	$(call run-in-container,root,nodejs, SHELL=/bin/bash yarn vitest run)

#######################
# CI #
#######################

ci-back-data-setup: ## for ci only
	$(call message,$(PROJECT_NAME): Installing Back end...)
	@$(MAKE) -s app-back-install
	$(call message,$(PROJECT_NAME): Back end is ready!)

ci-back-test: ## for ci only
	$(call message,$(PROJECT_NAME): Testing Back end...)
	$(call run-in-container,www-data,php,vendor/bin/pint --test \
	&& vendor/bin/pest && vendor/bin/phpstan analyze --memory-limit=-1)
	$(call message,$(PROJECT_NAME): Back end is ready!)

ci-front-data-setup: ## for ci only
	$(call message,$(PROJECT_NAME): Installing Front end...)
	$(call run-in-container,root,nodejs,SHELL=/bin/bash yarn cache clean --all && yarn \
	 && yarn build)
	$(call message,$(PROJECT_NAME): Front end is ready!)

ci-front-test: ## for ci only
	$(call message,$(PROJECT_NAME): Testing Back end...)
	@$(MAKE) -s ci-front-data-setup
	$(call run-in-container,root,nodejs,SHELL=/bin/bash yarn lint && yarn format && yarn test:unit)
	$(call message,$(PROJECT_NAME): Front end is ready!)

#######################
# Database #
#######################

db\:dump: ## to dumb db
	$(call message,$(PROJECT_NAME): Creating DB dump...)
	$(call run-in-container,root,database,mariadb-dump -u root laravel_db > db/db-latest.sql)
	$(call message,$(PROJECT_NAME): Done!)

db\:import: ## to import db
	$(call message,$(PROJECT_NAME): Importing DB...)
	$(call run-in-container,root,database,mariadb -u root laravel_db < db/db.sql)
	$(call message,$(PROJECT_NAME): Done!)

