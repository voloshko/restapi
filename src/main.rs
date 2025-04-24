fn main() {
    println!("Hello, world!");
}
use axum::{
    routing::get,
    Router,
};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    // Build our application with a single route.
    let app = Router::new().route("/", get(root));

    // Define the address to run the server on.
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    println!("listening on {}", addr);

    // Run the server.
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

// Basic handler that responds with a static string.
async fn root() -> &'static str {
    "Hello, World!"
}
