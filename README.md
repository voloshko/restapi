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

You can either build locally or use the pre-built image from GitHub Container Registry.

### Option 1: Build Locally
1.  **Build the Docker image:**
    ```bash
    docker build -t restapi-server .
    ```

2.  **Run the Docker container:**
    ```bash
    docker run -d -p 3000:3000 --name my-restapi-container restapi-server
    ```
    This runs the container in detached mode and maps port 3000.

### Option 2: Use Pre-built Image from GHCR
The container image is automatically built and published to GitHub Container Registry. You can pull it with:

```bash
docker pull ghcr.io/voloshko/restapi:latest
```

Then run it with:
```bash
docker run -d -p 3000:3000 --name my-restapi-container ghcr.io/voloshko/restapi:latest
```

> **Note:** You may need to authenticate first:
> ```bash
> echo $GITHUB_TOKEN | docker login ghcr.io -u voloshko --password-stdin
> ```

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

## Deploying to a Local Kubernetes Cluster (e.g., Minikube, Kind, MicroK8s, Docker Desktop)

1.  **Prerequisites:**
    *   A running local Kubernetes cluster (like MicroK8s).
    *   `kubectl` (or `microk8s kubectl`) configured to interact with your cluster.
    *   The Docker image `restapi-server:latest` built (see "Building and Running with Docker" above).

2.  **Load Docker Image into Cluster:**
    Make the locally built `restapi-server:latest` image available to your cluster. The command depends on your specific local cluster tool:
    *   **MicroK8s:**
        ```bash
        docker save restapi-server:latest > restapi-server.tar
        microk8s ctr image import restapi-server.tar
        rm restapi-server.tar 
        ```
        *(Ensure the MicroK8s container runtime (`ctr`) is enabled: `microk8s status --wait-ready`)*
    *   **Minikube:** `minikube image load restapi-server:latest`
    *   **Kind:** `kind load docker-image restapi-server:latest`
    *   **k3d:** `k3d image import restapi-server:latest`
    *   **Docker Desktop:** Usually works automatically if Kubernetes is enabled, as it shares Docker's image cache. Ensure `imagePullPolicy: IfNotPresent` or `imagePullPolicy: Never` is set in the deployment manifest.

3.  **Create Kubernetes Manifests:**
    Create the following two files in your project root:

    *   `deployment.yaml`:
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: restapi-deployment
        spec:
          replicas: 2
          selector:
            matchLabels:
              app: restapi
          template:
            metadata:
              labels:
                app: restapi
            spec:
              containers:
                - name: restapi-container
                  image: ghcr.io/voloshko/restapi:latest
                  imagePullPolicy: Always
                  ports:
                    - containerPort: 3000
        ```

    *   `service.yaml`:
        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          name: restapi-service
        spec:
          type: NodePort
          selector:
            app: restapi
          ports:
            - protocol: TCP
              port: 3000
              targetPort: 3000
              # nodePort: 30080 # Optional static NodePort
        ```

4.  **Apply Manifests:**
    Apply the deployment and service configurations to your cluster:
    ```bash
    microk8s kubectl apply -f deployment.yaml
    microk8s kubectl apply -f service.yaml
    ```

5.  **Access the Service:**
    *   Find the NodePort assigned to the service:
        ```bash
        microk8s kubectl get service restapi-service
        ```
        Look for the port mapping under the `PORT(S)` column (e.g., `3000:3XXXX/TCP`). The `3XXXX` part is the NodePort.
    *   Find the IP address of your cluster node (this varies depending on the tool):
        *   **MicroK8s:** Often the machine's primary IP, or try `microk8s kubectl get node -o wide` to find an EXTERNAL-IP or INTERNAL-IP. `localhost` might also work if accessing from the same machine.
        *   **Minikube:** `minikube ip`
        *   **Kind/Docker Desktop:** Usually `localhost` or `127.0.0.1` works.
    *   Access the service using the Node IP and NodePort:
        ```bash
        # Replace <NodeIP> and <NodePort> with the values you found
        curl http://<NodeIP>:<NodePort>
        ```
    *   Alternatively, use port-forwarding (runs in the foreground):
        ```bash
        microk8s kubectl port-forward service/restapi-service 8080:3000
        ```
        Then access via `curl http://localhost:8080` in another terminal.

6.  **Clean Up:**
    To remove the deployment and service from your cluster:
    ```bash
    microk8s kubectl delete -f service.yaml
    microk8s kubectl delete -f deployment.yaml
    ```
