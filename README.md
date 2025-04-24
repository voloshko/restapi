# Rust REST API Server

This is a simple REST API server built with Rust and the Axum framework.

## Prerequisites

*   [Rust](https://www.rust-lang.org/tools/install) (latest stable version recommended)
*   [Docker](https://docs.docker.com/get-docker/) (optional, for containerized deployment)

## Building and Running Locally

1.  **Build the project:**
    ```bash
    cargo build
    ```
    For a release build (optimized):
    ```bash
    cargo build --release
    ```

2.  **Run the server:**
    ```bash
    cargo run
    ```
    The server will start listening on `0.0.0.0:3000`.

## Building and Running with Docker

1.  **Build the Docker image:**
    ```bash
    docker build -t restapi-server .
    ```

2.  **Run the Docker container:**
    ```bash
    docker run -d -p 3000:3000 --name my-restapi-container restapi-server
    ```
    This runs the container in detached mode and maps port 3000.

## Testing the API

Once the server is running (either locally or in Docker), you can test the root endpoint using `curl`:

```bash
curl http://localhost:3000
```

You should see the response: `Hello, World! Hello Dennis`

## Stopping the Docker Container

If you ran the server using Docker, you can stop and remove the container with:

```bash
docker stop my-restapi-container
docker rm my-restapi-container
```
