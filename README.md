# GemStone/S 64 CI

[![GS64-3.6.6](https://img.shields.io/badge/GS64-3.6.6-informational)](https://gemtalksystems.com/products/gs64/)

A docker-based GitHub action to load and test code in a GemStone/S 64 image.

## Quick start

Create a workflow file in your project on `.github/worfklows` using this action.

For example:

```yml
name: 'GS64 Unit Tests'

on: [push,pull,workflow_dispatch]

jobs:
  testing:
    runs-on: ubuntu-latest
    name: GS64 Unit Tests
    steps:
      - uses: actions/checkout@v3
      - name: Load code and run tests
        uses: ba-st-actions/gs64-ci@v1
        with:
          project_name: 'Currency-API'
          run_tests: 'true'
```

## Supported inputs

- `project_name` Name of the project under test. Required.
- `load_spec` Name of the load spec to use. Optional, defaults to `{project_name}-CI`
- `run_tests` If `true` the action will run the tests of the project after loading
  the code. Optional, defaults to false.
