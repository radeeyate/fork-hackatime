FROM golang:1.18-alpine AS build-env
WORKDIR /src

# Required for go-sqlite3
RUN apk add --no-cache gcc musl-dev

RUN wget "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" -O wait-for-it.sh && \
    chmod +x wait-for-it.sh

ADD ./go.mod ./go.sum ./
RUN go mod download
ADD . .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" -v -o wakapi main.go

WORKDIR /staging
RUN mkdir ./data ./app && \
    cp /src/wakapi app/ && \
    cp /src/config.default.yml app/config.yml && \
    sed -i 's/listen_ipv6: ::1/listen_ipv6: /g' app/config.yml && \
    cp /src/wait-for-it.sh app/ && \
    cp /src/entrypoint.sh app/

# Run Stage

# When running the application using `docker run`, you can pass environment variables
# to override config values using `-e` syntax.
# Available options can be found in [README.md#-configuration](README.md#-configuration)

FROM alpine:3
WORKDIR /app

RUN apk add --no-cache bash ca-certificates tzdata

# See README.md and config.default.yml for all config options
ENV ENVIRONMENT=prod \
    WAKAPI_DB_TYPE=sqlite3 \
    WAKAPI_DB_USER='' \
    WAKAPI_DB_PASSWORD='' \
    WAKAPI_DB_HOST='' \
    WAKAPI_DB_NAME=/data/wakapi.db \
    WAKAPI_PASSWORD_SALT='' \
    WAKAPI_LISTEN_IPV4='0.0.0.0' \
    WAKAPI_INSECURE_COOKIES='true' \
    WAKAPI_ALLOW_SIGNUP='true'

COPY --from=build-env /staging /

EXPOSE 3000

ENTRYPOINT /app/entrypoint.sh
