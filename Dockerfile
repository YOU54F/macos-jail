# docker build -t you54f/pact-broker-darwin:latest
# docker run --rm -it you54f/pact-broker-darwin:latest 'pact-mock-service'
# docker run --rm -it you54f/pact-broker-darwin:latest 'pact-broker version'
# docker run --rm -it you54f/pact-broker-darwin:latest 'pact-broker-app version'
# docker run --rm -it you54f/pact-broker-darwin:latest # Runs a pact broker by default
# docker run --rm -it you54f/pact-broker-darwin:latest sh # Runs a shell

FROM ghcr.io/macoscontainers/macos-jail/ventura:latest
WORKDIR /root
ENV HOME=/root
ENV PATH=${HOME}/.pact/bin:${HOME}/.pact:${PATH}
RUN curl -fsSL https://raw.githubusercontent.com/YOU54F/traveling-ruby/traveling-pact/cli.sh | bash || true
RUN mv .pact/pact-broker-app.sh .pact/pact-broker-app && \
    mv .pact/pact-broker.sh .pact/pact-broker && \
    mv .pact/pact-message.sh .pact/pact-message && \
    mv .pact/pact-mock-service.sh .pact/pact-mock-service && \
    mv .pact/pact-provider-verifier.sh .pact/pact-provider-verifier && \
    mv .pact/pact-publish.sh .pact/pact-publish && \
    mv .pact/pact-stub-service.sh .pact/pact-stub-service && \
    mv .pact/pact.sh .pact/pact && \
    mv .pact/pactflow.sh .pact/pactflow
RUN ruby --version
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "pact-broker-app" ]