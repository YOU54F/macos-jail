# docker build -t you54f/go-darwin:latest
# docker run --rm -it you54f/go-darwin:latest

FROM ghcr.io/macoscontainers/macos-jail/ventura:latest
WORKDIR /root
ENV HOME=/root
ENV PATH=${HOME}/go/bin:${HOME}/.pact:${PATH}
RUN curl -LO https://go.dev/dl/go1.21.2.darwin-arm64.tar.gz && \
    tar -C ${HOME} -xzf go1.21.2.darwin-arm64.tar.gz && \
    rm go1.21.2.darwin-arm64.tar.gz
RUN go version
RUN mkdir /tmp
RUN echo "package main\\n\
import \"fmt\"\\n\
func main() {\\n\
    fmt.Println(\"hello world\")\\n\
}" > hello-world.go
RUN cat hello-world.go
RUN go run hello-world.go
RUN go build hello-world.go && \
    ./hello-world
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "./hello-world" ]