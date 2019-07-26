PYTHON     = python3.7 -m pipenv run
SRC_FILES := $(shell find . -name "*.py")

.PHONY: help
help:
	@echo "Usage:"
	@echo "    help:                Prints this screen"
	@echo "    install-deps:        Installs dependencies in the internal venv"
	@echo "    install-docker-deps: Installs dependencies for docker"
	@echo "    format:              Formats the code"
	@echo "    fmt:                 An alias for format"
	@echo "    lint:                Lints the code"
	@echo "    test:                Tests the code"
	@echo "    run:                 Run the flask application"
	@echo "    docker-build:        Build the docker containers"
	@echo "    up:                  Bring up the dockerized version of the app"
	@echo "    down                 Bring down the dockerized version of the app"
	@echo "    clean:               Clean out temporaries"
	@echo "    clean-full:          Clean out temporaries and the internal venv"
	@echo ""

.PHONY: install-deps
install-deps:
	$(PYTHON) pipenv install --dev


.PHONY: install-docker-deps
install-docker-deps:
	$(PYTHON) pipenv install --system --deploy --ignore-pipfile

.PHONY: format
format:
	 $(PYTHON) autopep8 -i $(SRC_FILES)

.PHONY: fmt
fmt: format

.PHONY: lint
lint:
	 $(PYTHON) mypy --ignore-missing-imports $(SRC_FILES)
	 $(PYTHON) pylint $(SRC_FILES)

.PHONY: test
test:
	 $(PYTHON) pytest tests

.PHONY: run
run:
	FLASK_APP=coa_flask_app FLASK_ENV=development $(PYTHON) uwsgi --ini deployment/uwsgi.ini

.PHONY: docker-build
docker-build:
	docker build . -t coa-flask-app
	cd deployment && docker build . -t coa-nginx

.PHONY: up
up: docker-build
	cd deployment && docker-compose up

.PHONY: down
down:
	cd deployment && docker-compose down

.PHONY:
clean:
	rm -rf "*.pyc" "__pycache__" ".mypy_cache" ".pytest_cache"

.PHONY: clean-full
clean-full: clean
	pipenv --rm clean
