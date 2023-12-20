use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Vote {
    #[key]
    id: u32,
    participant_address: ContractAddress, // Address of the participant casting the vote.
    proposal_id: u32,
    option_id: u8,
    vote_weight: u32, // Weight of the vote indicating the strength or number of votes.
}
