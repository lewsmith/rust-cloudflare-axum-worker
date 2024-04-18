use cfg_if::cfg_if;

cfg_if! {
    if #[cfg(feature = "console_error_panic_hook")] {
        extern crate console_error_panic_hook;
        #[inline]
        pub fn set_panic_hook() {
            worker::console_log!("Setting up panic hook...");
            console_error_panic_hook::set_once();
        }
    } else {
        #[inline]
        pub fn set_panic_hook() {}
    }
}
