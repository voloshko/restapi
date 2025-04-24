# Stage 1: Build the application
FROM rust:1.78 as builder

# Set the working directory
WORKDIR /usr/src/app

# Copy the Cargo configuration files
COPY Cargo.toml Cargo.lock ./

# Build dependencies first to leverage Docker cache
# Create a dummy main.rs to build only dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
# Remove dummy file after building dependencies
RUN rm -f src/main.rs

# Copy the actual source code
COPY src ./src

# Build the application, removing the old target directory first
RUN rm -rf target/release/deps/restapi*
RUN cargo build --release

# Stage 2: Create the final runtime image
FROM debian:slim-bullseye

# Set the working directory
WORKDIR /usr/local/bin

# Copy the built binary from the builder stage
COPY --from=builder /usr/src/app/target/release/restapi .

# Expose the port the application listens on
EXPOSE 3000

# Set the command to run the application
CMD ["./restapi"]
