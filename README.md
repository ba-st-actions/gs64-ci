# GemStone/S 64 CI

[![GS64-3.6.6](https://img.shields.io/badge/GS64-3.6.6-informational)](https://gemtalksystems.com/products/gs64/)
[![GS64-3.7.0](https://img.shields.io/badge/GS64-3.7.0-informational)](https://gemtalksystems.com/products/gs64/)

A docker-based GitHub action to load and test code in a GemStone/S 64 image.

This is a community project not endorsed by [GemTalk](https://gemtalksystems.com),
using the unofficial docker images available [here](https://github.com/ba-st/Docker-GemStone-64).

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
        uses: ba-st-actions/gs64-ci@v2
        with:
          project_name: 'Currency-API'
          run_tests: 'true'
```

- `v1` supports GS64 3.6.6
- `v2` supports GS64 3.7.0

When running, the workflow will map the `{GITHUB_WORKSPACE}` directory of the
runner to `{ROWAN_PROJECTS_HOME}/{project_name}` inside the container running GS.
So the repository contents previously checked out are available in the directory
expected by rowan.

## Supported inputs

- `project_name` Name of the project under test. Required.
- `load_spec` Name of the load spec to use. Optional, defaults to `{project_name}-CI`
- `run_tests` If `true` the action will run the tests of the project after loading
  the code. Optional, defaults to false.
