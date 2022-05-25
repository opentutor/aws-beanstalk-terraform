# Lambda Function for Automatic (new) LogGroup Subscription

## Conventions

The following tools and conventions are used within this project:

- [pipenv](https://github.com/pypa/pipenv) for managing Python dependencies and development virtualenv
- [flake8](https://github.com/PyCQA/flake8) & [radon](https://github.com/rubik/radon) for linting and static code analysis
- [isort](https://github.com/timothycrosley/isort) for import statement formatting
- [black](https://github.com/ambv/black) for code formatting
- [mypy](https://github.com/python/mypy) for static type checking

## Getting Started

The following instructions will help you get setup for local development and testing purposes.

### Prerequisites

#### [Pipenv](https://github.com/pypa/pipenv)

Pipenv is used to help manage the python dependencies and local virtualenv for local testing and development. To install `pipenv` please refer to the project [installation documentation](https://github.com/pypa/pipenv#installation).

Install the projects Python dependencies (with development dependencies) locally by running the following command.

```bash
  $ pipenv install --dev
```

If you add/change/modify any of the Pipfile dependencies, you can update your local virtualenv using:

```bash
  $ pipenv update
```
