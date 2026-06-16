.DEFAULT_GOAL := help
VENV ?= .venv
PY ?= $(VENV)/bin/python
PIP ?= $(VENV)/bin/pip

.PHONY: help install serve build strict test lint clean

help:
	@echo "AIStack — common targets"
	@echo ""
	@echo "  make install   create .venv and install dev + docs extras"
	@echo "  make serve     preview the docs site at http://127.0.0.1:8000"
	@echo "  make build     build the static docs site into ./site"
	@echo "  make strict    build with --strict (fails on warnings — CI uses this)"
	@echo "  make test      run pytest"
	@echo "  make lint      run ruff"
	@echo "  make clean     remove build artifacts"

$(VENV)/bin/activate:
	python3 -m venv $(VENV)

install: $(VENV)/bin/activate
	$(PIP) install -U pip
	$(PIP) install -e ".[docs,dev]"

serve:
	$(VENV)/bin/mkdocs serve

build:
	$(VENV)/bin/mkdocs build

strict:
	$(VENV)/bin/mkdocs build --strict

test:
	$(VENV)/bin/pytest -q

lint:
	$(VENV)/bin/ruff check .

clean:
	rm -rf site .pytest_cache .ruff_cache build dist *.egg-info
