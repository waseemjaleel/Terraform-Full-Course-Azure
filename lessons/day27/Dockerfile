FROM golang:1.23 AS build
# Set the working directory
WORKDIR /go/src/app  
# Copy only the necessary files from parent directory
COPY . .

RUN go mod download
RUN go vet -v
RUN go test -v

RUN CGO_ENABLED=0 go build -o /go/bin/app

FROM gcr.io/distroless/static-debian12

EXPOSE 8080

COPY --from=build /go/bin/app /
COPY --from=build /go/src/app/kodata /kodata

ENV KO_DATA_PATH="/kodata"

CMD ["/app"]