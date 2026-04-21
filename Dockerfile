FROM golang:1.21-alpine AS builder

WORKDIR /app

# Копируем только go.mod для кэширования
COPY go.mod ./

# Загружаем зависимости с флагом -mod=mod (авто-обновление go.sum)
ENV GOFLAGS=-mod=mod
RUN go mod download

# Копируем исходники ПОСЛЕ загрузки зависимостей
COPY . .

# Собираем с тем же флагом -mod=mod, чтобы Go сам подтянул go.sum при необходимости
RUN CGO_ENABLED=0 GOOS=linux go build -mod=mod -a -installsuffix cgo -o main .

# Минимальный финальный образ
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]