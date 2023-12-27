use starknet::ContractAddress;

// Represents a summary of votes for a particular option in a proposal 
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct OptionSummary {
    #[key]
    proposal_id: u32,
    #[key]
    option_id: u8,
    participant_count: u32, // Total number of participants who have voted for this option.
    total_weight: u32, // Sum of the weight of all votes cast for this option.
}
