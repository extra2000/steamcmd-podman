FROM docker.io/library/python:3.7-buster

# Packages for building documentations
RUN python3 -m pip install sphinx sphinx-rtd-theme sphinx-rtd-dark-mode sphinxcontrib-napoleon sphinxcontrib-programoutput

WORKDIR /srv/docs
