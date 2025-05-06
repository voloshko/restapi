use axum::{routing::get, Router};
use std::net::SocketAddr;
use std::env;

#[tokio::main]
async fn main() {
    // Build our application with a single route.
    let app = Router::new().route("/", get(root));

    // Get port from environment or use default
    let port = env::var("PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(3000);
    
    // Define the address to run the server on.
    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("listening on {}", addr);

    // Run the server.
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

// Basic handler that responds with a concatenated string.
async fn root() -> String {
    format!("Heya! 🌈 What's up, Dennis? miru mir mne plombir!!!! AI!")
}
