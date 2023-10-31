# runtime envrionment
ARG PREFIX=prefix
ARG BASE_TAG=tag
ARG BASE_IMAGE=image
FROM ${PREFIX}/${BASE_IMAGE}:${BASE_TAG} as builder

RUN pip install -r /data/projects/python/requirements-fate.txt -r /data/projects/python/requirements-eggroll.txt