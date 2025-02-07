FROM ghcr.io/modular/magic:latest

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/Lightbug-HQ/lightbug_http

WORKDIR /lightbug_http

ARG SERVER_PORT=8080
EXPOSE ${SERVER_PORT}

ENV APP_ENTRYPOINT=lightbug.🔥
CMD magic run mojo ${APP_ENTRYPOINT}
