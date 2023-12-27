use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Vote {
    #[key]
    participant_address: ContractAddress, // Address of the participant casting the vote.
    #[key]
    proposal_id: u32,
    id: u32, // vote id, no use
    option_id: u8,
    vote_weight: u32, // Weight of the vote indicating the strength or number of votes.
}
