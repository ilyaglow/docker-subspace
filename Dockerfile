FROM golang:latest as build
LABEL original_repo=github.com/soundscapecloud/soundscape \
      fork_repo=github.com/BankaiNoJutsu/subspace \
      maintainer="Ilya Glotov <ilya@ilyaglotov.com>"

ENV GODEBUG="netdns=go http2server=0" \
    GOPATH="/go"

ARG BUILD_VERSION=unknown

WORKDIR /go/src/github.com/BankaiNoJutsu

RUN apt-get update \
    && apt-get install -y git \
    && git clone --branch master --depth=1 https://github.com/BankaiNoJutsu/subspace \
    && cd subspace \
    && go get -v \
         github.com/jteeuwen/go-bindata/... \
         github.com/dustin/go-humanize \
         github.com/julienschmidt/httprouter \
         github.com/Sirupsen/logrus \
         github.com/gorilla/securecookie \
         golang.org/x/crypto/acme/autocert \
         golang.org/x/time/rate \
         golang.org/x/crypto/bcrypt \
         go.uber.org/zap \
         gopkg.in/gomail.v2 \
         github.com/jasonlvhit/gocron \
    && go-bindata --pkg main static/... templates/... email/... \
    && go build -v --compiler gc --ldflags "-extldflags -static -s -w -X main.version=${BUILD_VERSION}" -o /subspace-linux-amd64 \
    && chmod +x entrypoint.sh \
    && rm -rf /var/lib/apt/lists/*

FROM alpine:latest
COPY --from=build /subspace-linux-amd64 /subspace-linux-amd64
COPY --from=build /go/src/github.com/BankaiNoJutsu/subspace/entrypoint.sh /entrypoint.sh

RUN apk --update --no-cache add iptables \
                                dnsmasq \
                                bash \
                                socat

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/my_init"]
