# syntax=docker/dockerfile:1.7

# Override to build against a locally built base, e.g. lancommander/halflife:local
ARG BASE_IMAGE=lancommander/halflife:latest
FROM ${BASE_IMAGE}

# Natural Selection runs on the stock Half-Life content (GAME_MOD=valve) and is
# downloaded from the community ENSL builds on top of it.
ENV NS_VERSION="v3.3b9"
ENV NS_URL=""
ENV START_ARGS="-game ns -console -port 27015 +maxplayers 24 +map ns_eon"
ENV HTTP_FILESERVER_WEB_ROOT="/config/Merged/ns"

# ----------------------------
# Dependencies
# ----------------------------
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
  && rm -rf /var/lib/apt/lists/*

COPY Hooks/ "${BASE_HOOKS}/"

USER lancommander

WORKDIR /config
ENTRYPOINT ["/usr/local/bin/entrypoint.ps1"]
