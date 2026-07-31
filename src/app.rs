use topcoat::{
    Result,
    router::{Router, layout, page},
    view::{component, view},
};

// The `module_router!()` macro call must be placed at the root of your route structure.
// In this case, the `app` module is marked as the root.
pub fn router() -> Router {
    topcoat::router::module_router!().build()
}

// A layout in the root app module wraps every page.
#[layout]
async fn root_layout(slot: Result) -> Result {
    view! {
        <!DOCTYPE html>
        <html>
            <head>
                <title>"Hello world"</title>
                topcoat::dev::script()
            </head>
            <body>(slot?)</body>
        </html>
    }
}

// A page in app.rs renders at /.
#[page]
async fn home() -> Result {
    view! { hello(name: "World") }
}

#[component]
async fn hello(name: &str) -> Result {
    view! {
        <h1>
            "Hello, "
            (name)
            "!"
        </h1>
    }
}
