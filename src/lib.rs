mod utils;

use std::{collections::HashMap, sync::Arc};

use askama::Template;
use axum::{
    body::Body,
    extract::State,
    http::{Response as AxumResponse, StatusCode},
    response::*,
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use tower_service::Service;
use worker::{event, Context, Env, HttpRequest, Var};

#[derive(Debug, Deserialize, Serialize)]
struct GenericJsonResponse {
    status: u16,
    message: String,
    vars: Option<HashMap<String, String>>,
}

#[derive(Clone)]
struct EnvWrapper {
    env: Arc<worker::Env>,
}

#[derive(Clone)]
pub struct AxumState {
    env_wrapper: EnvWrapper,
}

#[derive(Template)]
#[template(path = "example.html")]
struct AskamaTemplate {
    environment_name: String,
}

#[event(start)]
fn start() {
    utils::set_panic_hook();
}

impl IntoResponse for GenericJsonResponse {
    fn into_response(self) -> AxumResponse<Body> {
        (
            StatusCode::OK,
            Json(GenericJsonResponse {
                status: self.status,
                message: self.message,
                vars: self.vars,
            }),
        )
            .into_response()
    }
}

#[event(fetch)]
async fn fetch(req: HttpRequest, env: Env, _ctx: Context) -> worker::Result<AxumResponse<Body>> {
    let axum_state = AxumState {
        env_wrapper: EnvWrapper { env: Arc::new(env) },
    };

    let mut router = Router::new()
        .route("/", get(handle_root))
        .route("/template", get(handle_template))
        .route("/json", get(handle_json))
        .with_state(axum_state);

    Ok(router.call(req).await.unwrap())
}

pub async fn handle_root() -> impl IntoResponse {
    Html("<h1>👋 Hello from the Worker.</h1>")
}

pub async fn handle_template(State(state): State<AxumState>) -> impl IntoResponse {
    let env: &Env = state.env_wrapper.env.as_ref();
    let environment_var = env.var("ENV").unwrap();

    let tpl = AskamaTemplate {
        environment_name: environment_var.to_string(),
    };

    Html(tpl.render().unwrap())
}

pub async fn handle_json(State(state): State<AxumState>) -> impl IntoResponse {
    let env: &Env = state.env_wrapper.env.as_ref();
    let environment_name: Var = env.var("ENV").unwrap();

    let mut vars = HashMap::new();
    vars.insert("ENV".to_string(), environment_name.to_string());

    GenericJsonResponse {
        status: 200,
        message: "Some JSON response message.".to_string(),
        vars: Some(vars),
    }
}
