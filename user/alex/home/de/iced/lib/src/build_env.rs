#[cfg(debug_assertions)]
#[macro_export]
macro_rules! build_env {
    ($name:literal, $fallback:expr) => {
        match option_env!($name) {
            Some(v) => v,
            None => $fallback,
        }
    };
}

#[cfg(not(debug_assertions))]
#[macro_export]
macro_rules! build_env {
    ($name:literal, $fallback:expr) => {
        env!($name, concat!($name, " is not set"))
    };
}
