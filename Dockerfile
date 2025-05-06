# Stage 1: Build the application
FROM rust:1.78 as builder

# Set the working directory
WORKDIR /usr/src/app

# Create empty project for initial build
RUN mkdir src && echo "fn main() {}" > src/main.rs
COPY Cargo.toml Cargo.lock ./

# Build dependencies first to leverage Docker cache
RUN cargo build --release

# Clean up dummy files
RUN rm -rf src

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
