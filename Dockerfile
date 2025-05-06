# Stage 1: Build the application
FROM rust:1.78 as builder

# Set the working directory
WORKDIR /usr/src/app

# Set working directory
WORKDIR /usr/src/app

# First copy only the files needed for dependency resolution
COPY Cargo.toml ./

# Copy source files and Cargo.lock
COPY src ./src
COPY Cargo.lock ./

# Generate lockfile if it doesn't exist
RUN if [ ! -f Cargo.lock ]; then cargo generate-lockfile; fi

# Clean any previous build and rebuild with real sources
RUN rm -rf target && \
    cargo build --release

# Copy the actual source code
COPY src ./src

# Build the application, removing the old target directory first
RUN rm -rf target/release/deps/restapi*
RUN cargo build --release

# Stage 2: Create the final runtime image
FROM debian:stable-slim
LABEL org.opencontainers.image.source="https://github.com/voloshko/restapi"
LABEL org.opencontainers.image.description="Rust REST API service"
LABEL org.opencontainers.image.licenses=MIT

# Set the working directory
WORKDIR /usr/local/bin

# Copy the built binary from the builder stage
COPY --from=builder /usr/src/app/target/release/restapi /usr/local/bin/

# Expose the port the application listens on
EXPOSE 3000

# Set environment variables
ENV PORT=3000

# Set the command to run the application
CMD ["restapi"]
