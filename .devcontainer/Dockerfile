FROM mcr.microsoft.com/devcontainers/base:debian

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y erlang && apt-get install -y rebar3

RUN rm -rf /var/lib/apt/lists/