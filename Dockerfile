FROM rust:1.41 as build

COPY ./ ./

RUN cargo build --release
RUN mkdir /out
RUN cp target/release/hello-world /out/

FROM ubuntu:18.04

COPY --from=build /out/hello-world /

CMD ["/hello-world"]
