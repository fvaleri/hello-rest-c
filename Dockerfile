FROM alpine:3.12 AS build
MAINTAINER Federico Valeri <fvaleri@localhost>
ENV NAME="hello-rest-c" \
    VERSION="1.0.0-SNAPSHOT" #EXTRA_LDFLAGS="-static"
RUN apk add --no-cache gcc make musl-dev libc-dev libmicrohttpd-dev git && \
    cd /tmp && \
    git clone https://github.com/fvaleri/hello-rest-c.git && \
    make -C hello-rest-c

FROM alpine:3.12
MAINTAINER Federico Valeri <fvaleri@localhost>
ENV HOME="/opt/app"
RUN apk add --no-cache libc6-compat libmicrohttpd && mkdir -p $HOME
COPY --from=build /tmp/hello-rest-c/hello-rest-c $HOME
USER 1001
WORKDIR $HOME
EXPOSE 8080
CMD ["/opt/app/hello-rest-c", "--debug"]
