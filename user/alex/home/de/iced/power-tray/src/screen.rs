use hmerr::ge;
use iced_layershell::reexport::{
    Anchor, KeyboardInteractivity, Layer, NewLayerShellSettings, OutputOption,
};

use crate::NAMESPACE;

const SIDE_VH: f32 = 6.0;

pub struct Screen {
    pub name: String,
    pub height: f32,
}

pub fn parse() -> hmerr::Result<Vec<Screen>> {
    let raw = std::env::var("WIDGET_TRAY_SCREEN").map_err(|e| {
        ge!(
            "WIDGET_TRAY_SCREEN not set",
            h: "expected \"<output>:<height>;...\", set by the power-tray service",
            s: e,
        )
    })?;

    Ok(raw
        .split(';')
        .filter_map(|pair| {
            let (name, height) = pair.split_once(':')?;
            Some(Screen {
                name: name.to_owned(),
                height: height.parse().ok()?,
            })
        })
        .collect())
}

impl Screen {
    pub fn side(&self) -> f32 {
        self.height * SIDE_VH / 100.0
    }

    pub fn surface(&self) -> NewLayerShellSettings {
        let square = self.side() as u32;
        NewLayerShellSettings {
            size: Some((square, square)),
            layer: Layer::Bottom,
            anchor: Anchor::Top | Anchor::Right,
            exclusive_zone: Some(0),
            margin: Some((0, 0, 0, 0)),
            keyboard_interactivity: KeyboardInteractivity::None,
            output_option: OutputOption::OutputName(self.name.clone()),
            events_transparent: false,
            namespace: Some(NAMESPACE.to_owned()),
        }
    }
}
