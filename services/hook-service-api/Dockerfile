FROM comum/pg-dispatcher:latest AS dispatcher-env

FROM node:9.1

RUN apt-get update
RUN apt-get update && apt-get install -y libssl-dev

COPY --from=dispatcher-env /usr/local/bin/pg-dispatcher /usr/local/bin/

ENV SENTRY_DSN_CONNECTION_URL=https://4b71475f8c67413a8c897d2ed56deb49:68c13d3166ba469b8473dcea2ca3a249@sentry.io/1311879
WORKDIR /usr/app

COPY . .

RUN npm install
