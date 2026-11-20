FROM golang:1.25-alpine AS dev

RUN apk add --no-cache git curl

RUN go install github.com/air-verse/air@v1.63.9

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV PATH="/go/bin:${PATH}"

EXPOSE 3001 8080

CMD ["air", "-c", ".air.toml"]
