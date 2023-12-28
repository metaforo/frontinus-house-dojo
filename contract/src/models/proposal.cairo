use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo_gov::models::option_summary::OptionSummary;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Proposal {
    #[key]
    id: u32,
    proposer_address: ContractAddress, // Address of the contract that created the proposal.
    metadata_url: MetadataUrl, // URL to the metadata of the proposal. 
    participant_count: u32, // mutable. Total number of participants who have voted.
    vote_count: u32, // mutable. Total number of votes cast across all options.
    start_block: u64, // Block number at which the proposal voting starts.
    end_block: u64, // Block number at which the proposal voting ends. Maybe 0.
    status: u32,
    contract_addr: ContractAddress,
    entrypoint: felt252,
    call_data: felt252,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct MetadataUrl {
    part1: felt252,
    part2: felt252,
}

mod ProposalStatus {
    const Undefined: u32 = 0;
    const Voting: u32 = 1; // Proposal is in the voting period.
    const Passed: u32 = 2; // Voting period ended, votes passed, proposal awaiting execution.
    const Rejected: u32 = 3; //  votes did not pass, proposal cannot be executed.
    const Executed: u32 = 4;
}

#[generate_trait]
impl ProposalImpl of ProposalTrait {
    fn refresh_status(ref self: Proposal, world: IWorldDispatcher) -> u32 {
        if (self.end_block == 0 || self.status != ProposalStatus::Voting) {
            return self.status;
        }

        let block_number = starknet::get_block_info().unbox().block_number;
        if (block_number >= self.end_block) {
            // Ended
            let option1 = get!(world, (self.id, 0), (OptionSummary));
            let option2 = get!(world, (self.id, 1), (OptionSummary));
            if (option1.total_weight > option2.total_weight) {
                self.status = ProposalStatus::Passed;
            } else {
                self.status = ProposalStatus::Rejected;
            }

            set!(world, (self));
        }

        self.status
    }
}