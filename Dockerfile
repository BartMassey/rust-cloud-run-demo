FROM debian:buster AS builder

# You'll need to replace the mariadb packages with `libpq-dev` here and below if you're using Postgres
RUN apt-get update && apt-get install -y build-essential curl libmariadb-dev-compat libmariadb-dev

# Install rust
RUN curl https://sh.rustup.rs/ -sSf | \
  sh -s -- -y --default-toolchain  nightly-2020-11-24

ENV PATH="/root/.cargo/bin:${PATH}"

ADD . ./

RUN cargo build --release

FROM debian:buster

# Change to libmysql
RUN apt-get update && apt-get install -y libmariadb-dev-compat libmariadb-dev

COPY --from=builder \
  /target/release/rocket-app \
  /usr/local/bin/

WORKDIR /root
CMD ROCKET_PORT=$PORT /usr/local/bin/rocket-app
