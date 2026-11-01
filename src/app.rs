mod todos;

use topcoat::{
    Result,
    asset::{AssetBundle, RouterBuilderAssetExt},
    context::Cx,
    font::{Font, fontsource::fontsource_font},
    icon::{icon, iconify::iconify_icon},
    router::{RouterBuilder, RouterBuilderDiscoverExt, Slot, href, layout, module_router, page},
    runtime::RuntimeLayer,
    tailwind,
    view::{View, attributes, view},
};

use crate::components::{
    button::{ButtonSize, ButtonVariant, button_variants},
    card::{card, card_content, card_description, card_header, card_title},
};

/// The Geist font family, loaded from Fontsource.
const GEIST: Font = fontsource_font!(GEIST, weight: [400, 700], style: Normal);

/// Builds the application's router.
pub fn router() -> RouterBuilder {
    // The pages and layouts of this module and its submodules, with paths derived
    // from the module tree.
    module_router!()
        // The runtime's procedures and shards, which have no place in the module tree.
        .discover()
        .assets(AssetBundle::load().unwrap())
        // Lets the browser runtime rerun pages; register it after other layers.
        .layer(RuntimeLayer::new())
}

#[layout]
async fn root(cx: &Cx, slot: Slot<'_>) -> Result<impl View> {
    Ok(view! {
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>"rust-topcoat-playground"</title>
                <link rel="stylesheet" href=(tailwind::stylesheet!())>
                topcoat::font::link(font: GEIST)
                topcoat::runtime::script()
                topcoat::dev::script()
            </head>
            <body>(slot)</body>
        </html>
    })
}

#[page]
async fn home(cx: &Cx) -> Result<impl View> {
    Ok(view! {
        <main class="mx-auto max-w-2xl px-4 py-16">
            card(
                card_header(
                    card_title(
                        icon(
                            data: iconify_icon!("lucide:sparkles"),
                            attrs: attributes! { class="inline-block" }
                        )
                        " "
                        "rust-topcoat-playground"
                    )
                    card_description(
                        "Edit "
                        <code>"src/app.rs"</code>
                        " and save to see your changes."
                    )
                )
                card_content(
                    // A link styled like a button, with the button component's classes.
                    <a
                        class=(button_variants(ButtonVariant::Primary, ButtonSize::Md))
                        href=(href!(todos::page))
                    >
                        "Todo example"
                    </a>
                )
            )
        </main>
    })
}
