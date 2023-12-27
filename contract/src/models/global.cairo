const CONFIG_KEY: u8 = 1;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct GlobalConfig {
    #[key]
    id: u32,
    proposal_count: u32,
    vote_count: u32,
}
