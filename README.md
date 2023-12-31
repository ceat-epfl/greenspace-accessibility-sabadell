<!-- prettier-ignore-start -->

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/ceat-epfl/greenspace-accessibility-sabadell/main.svg)](https://results.pre-commit.ci/latest/github/ceat-epfl/greenspace-accessibility-sabadell/main)
[![GitHub license](https://img.shields.io/github/license/martibosch/greenspace-accessibility-sabadell.svg)](https://github.com/martibosch/greenspace-accessibility-sabadell/blob/main/LICENSE)

<!-- prettier-ignore-end -->

# Accessibility to urban greenspaces with different vegetation maps in Sabedell

Study of the accessibility of urban greenspaces with different vegetation maps (NDVI, LULC and imagery): a case study in Sabadell, Catalonia

## Requirements

- [mamba](https://github.com/mamba-org/mamba), which can be installed using conda or [mambaforge](https://github.com/conda-forge/miniforge#mambaforge) (see [the official installation instructions](https://github.com/mamba-org/mamba#installation))
- [snakemake](https://snakemake.github.io), which can be installed using [conda or mamba](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)

## Instructions

1. Create a conda environment:

```bash
snakemake -c1 create_environment
```

2. Activate it (if using conda, replace `mamba` for `conda`):

```bash
mamba activate greenspace-accessibility-sabadell
```

3. Register the IPython kernel for Jupyter:

```bash
snakemake -c1 register_ipykernel
```

4. Create a git repository:

```bash
git init
```

5. Activate pre-commit for the git repository:

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

6. Create the first commit:

```bash
git add .
git commit -m "feat: initial commit"
```

7. Enjoy! :rocket:

## Acknowledgments

- Based on the [cookiecutter-data-snake :snake:](https://github.com/martibosch/cookiecutter-data-snake) template for reproducible data science.
