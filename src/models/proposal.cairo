use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

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
    status: ProposalStatus,
    contract_addr: ContractAddress,
    entrypoint: felt252,
    call_data: felt252,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct MetadataUrl {
    part1: felt252,
    part2: felt252,
}

#[derive(Serde, Copy, Drop, PartialEq, Introspect)]
enum ProposalStatus {
    Undefined,
    Open,
    Ended,
}

impl ProposalStatusIntoFelt252 of Into<ProposalStatus, felt252> {
    fn into(self: ProposalStatus) -> felt252 {
        match self {
            ProposalStatus::Undefined => 0,
            ProposalStatus::Open => 1,
            ProposalStatus::Ended => 2,
        }
    }
}

#[generate_trait]
impl ProposalImpl of ProposalTrait {
    fn refresh_status(ref self: Proposal, world: IWorldDispatcher) -> ProposalStatus {
        if (self.end_block == 0 || self.status != ProposalStatus::Open) {
            return self.status;
        }

        let block_number = starknet::get_block_info().unbox().block_number;
        if (block_number >= self.end_block) {
            self.status = ProposalStatus::Ended;
            set!(world, (self));
        }

        self.status
    }
}
