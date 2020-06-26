FROM alpine:3.12 AS build
ENV NAME="hello-rest-c" \
    VERSION="1.0.0-SNAPSHOT"
RUN apk add --no-cache git build-base && \
    cd /tmp && \
    wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz && \
    tar xfz libmicrohttpd-latest.tar.gz && \
    (cd libmi*; ./configure; make install) && \
    git clone https://github.com/fvaleri/hello-rest-c.git && \
    make -C hello-rest-c

FROM alpine:3.12
MAINTAINER Federico Valeri <fvaleri@localhost>
ENV HOME="/opt/app"
RUN mkdir -p $HOME
COPY --from=build /usr/local/lib/libmicrohttpd.so* /usr/local/lib
COPY --from=build /tmp/hello-rest-c/hello-rest-c $HOME
USER 1001
WORKDIR $HOME
EXPOSE 8080
CMD ["/opt/app/hello-rest-c", "--debug"]
