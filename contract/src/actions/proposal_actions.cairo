use dojo_gov::models::proposal::{MetadataUrl};
use starknet::ContractAddress;

#[starknet::interface]
trait IProposalActions<TContractState> {
    fn create(
        self: @TContractState,
        end_block: u64,
        metadata_url: MetadataUrl,
        contract_addr: ContractAddress,
        entrypoint: felt252,
        call_data: felt252,
    ) -> u32;

    fn execute(self: @TContractState, proposal_id: u32);
}

#[dojo::contract]
mod proposal_actions {
    use starknet::ContractAddress;
    use dojo_gov::models::proposal::{Proposal, ProposalStatus, ProposalTrait};
    use dojo_gov::models::global::{CONFIG_KEY, GlobalConfig};
    use dojo_gov::models::option_summary::OptionSummary;
    use super::IProposalActions;
    use dojo_gov::models::proposal::{MetadataUrl};
    use core::serde::Serde;
    use starknet::SyscallResultTrait;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ProposalCreated: ProposalCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct ProposalCreated {
        id: u32,
        proposal: Proposal,
    }

    #[external(v0)]
    impl ProposalActionsImpl of IProposalActions<ContractState> {
        fn create(
            self: @ContractState,
            end_block: u64,
            metadata_url: MetadataUrl,
            contract_addr: ContractAddress,
            entrypoint: felt252,
            call_data: felt252,
        ) -> u32 {
            let world = self.world_dispatcher.read();

            // Ensure the end_block is either zero (indicating no set end block) or greater than the start_block.
            let start_block = starknet::get_block_info().unbox().block_number;
            assert(end_block == 0 || end_block > start_block, 'end block invalid');

            let mut cfg = get!(world, CONFIG_KEY, (GlobalConfig));
            cfg.proposal_count += 1;
            let proposer_address = starknet::get_caller_address();
            let id = cfg.proposal_count;
            let proposal = Proposal {
                id,
                proposer_address,
                metadata_url,
                start_block,
                end_block,
                participant_count: 0,
                vote_count: 0,
                status: ProposalStatus::Voting,
                contract_addr,
                entrypoint,
                call_data,
            };

            set!(world, (cfg, proposal));

            emit!(world, ProposalCreated { id, proposal });

            id
        }

        fn execute(self: @ContractState, proposal_id: u32) {
            let world = self.world_dispatcher.read();
            let mut proposal = get!(world, proposal_id, (Proposal));
            // TODO : dont check proposal status for dev
            // let status = proposal.refresh_status(world);
            // assert(status != ProposalStatus::Executed, 'proposal has executed');
            // assert(status != ProposalStatus::Voting, 'proposal not end');
            // assert(status == ProposalStatus::Passed, 'proposal not passed');

            let mut call_data: Array<felt252> = ArrayTrait::new();
            Serde::serialize(@proposal.call_data, ref call_data);
            let mut res = starknet::call_contract_syscall(
                proposal.contract_addr, proposal.entrypoint, call_data.span(),
            );

            proposal.status = ProposalStatus::Executed;
            set!(world, (proposal));
        }
    }
}

#[cfg(test)]
mod proposal_tests {
    use dojo_gov::actions::proposal_actions::{IProposalActionsDispatcherTrait};
    use dojo_gov::models::global::{CONFIG_KEY, GlobalConfig};
    use dojo_gov::models::proposal::{Proposal, ProposalStatus, MetadataUrl};
    use dojo_gov::tests::{init_world, DefaultWorld};
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};

    #[test]
    #[available_gas(3000000000)]
    fn test_create_proposal() {
        let DefaultWorld{world, proposal_actions, caller, .. } = init_world();
        let proposal_id = proposal_actions
            .create(
                12871283,
                MetadataUrl { part1: 'tGHSppCUlx5VokPISjRefDy8QPVuzj', part2: 'CIftsTYJzHP4w' },
                starknet::contract_address_const::<0x1>(),
                1,
                23,
            );
        assert(proposal_id == 1, 'proposal id incorrect');

        let cfg = get!(world, CONFIG_KEY, GlobalConfig);
        assert(cfg.proposal_count == proposal_id, 'wrong global config');

        let proposal = get!(world, (proposal_id), Proposal);
        assert(proposal.status == ProposalStatus::Voting, 'wrong proposal init status');
        assert(proposal.proposer_address == caller, 'wrong proposal creater');
    }
}
