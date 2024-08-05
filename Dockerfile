FROM golang:1.22.5-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o myurls
FROM alpine:latest
ARG TZ=Asia/Shanghai
RUN apk --no-cache add tzdata && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
WORKDIR /app
COPY --from=builder /app/myurls ./
COPY etc/docker-myurls.yaml ./etc/myurls.yaml
ENV REDIS_TYPE=node REDIS_PASS= REDIS_TLS=false \
    WebSiteURL=http://127.0.0.1:8888 ShortKeyLength=7 ShortKeyTTL=604800
ENTRYPOINT ["./myurls"]
