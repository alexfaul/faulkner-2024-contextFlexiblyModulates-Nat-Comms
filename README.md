# Faulkner-et-al-2024

This repository includes code for reproducing main results and figures for the paper "Context flexibly modulates cue representations in visual cortex" submitted to Nature Communications.

## System Requirements

### Hardware requirements

The provided code can be run on any standard computer with enough memory to perform the necessary operations.

### Software requirements

Running the provided code requires a working installation of Python 3 (the code has been tested on a Python 3.10 environment).
All required Python modules (along with versions that the code has been tested with) are provided in the [requirements.txt](requirements.txt) file.

## Installation

Using a working installation of Python with pip, run `pip install -r requirements.txt` to all requirements.
This also installs JupyterLab for running the provided notebooks.
Installation can take a few minutes depending on your system.

## Demo
### Notebooks

The [notebooks](notebooks/) directory contains Jupyter notebooks for reproducing main results and figures in the paper.
The underlying data for reproducing these results is provided in the [data](data/) directory.
Run the following in a command line terminal (from the repository directory) to start JupyterLab:
```
cd notebooks
jupyter lab
```

This will automatically open JupyerLab in your browser.
From there you can open and run the provided notebooks.
The following notebooks are provided:
- [pca.ipynb](notebooks/pca.ipynb): User to generated Figures 6/S6 in the paper.
- To be completed...
