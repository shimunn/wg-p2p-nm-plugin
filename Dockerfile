FROM fedora:29

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain none -y

ENV PATH=$PATH:/root/.cargo/bin

COPY fedora-deps.sh /tmp/

RUN rustup toolchain install nightly-2018-08-01 && /tmp/fedora-deps.sh && rm /tmp/fedora-deps.sh

COPY . /build

WORKDIR /build

RUN rustup run nightly-2018-08-01 cargo build --release; /bin/true
