mod utils;

use axum::{
    body::Body,
    http::{Response as AxumResponse, StatusCode},
    response::*,
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use tower_service::Service;
use worker::*;

#[derive(Debug, Deserialize, Serialize)]
struct GenericResponse {
    status: u16,
    message: String,
}

#[event(start)]
fn start() {
    utils::set_panic_hook();
}

impl IntoResponse for GenericResponse {
    fn into_response(self) -> AxumResponse<Body> {
        (
            StatusCode::OK,
            Json(GenericResponse {
                status: self.status,
                message: self.message,
            }),
        )
            .into_response()
    }
}

#[event(fetch)]
async fn fetch(req: HttpRequest, _env: Env, _ctx: Context) -> worker::Result<AxumResponse<Body>> {
    let mut router = Router::new()
        .route("/", get(handle_root))
        .route("/api", get(handle_api));

    Ok(router.call(req).await.unwrap())
}

pub async fn handle_root() -> impl IntoResponse {
    Html("<h1>👋 Hello from the Worker.</h1>")
}

pub async fn handle_api() -> impl IntoResponse {
    GenericResponse {
        status: 200,
        message: "Some API response".to_string(),
    }
}
