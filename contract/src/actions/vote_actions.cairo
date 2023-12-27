use starknet::ContractAddress;

#[starknet::interface]
trait IVoteActions<TContractState> {
    // Adds a vote for an option in a proposal.
    fn create(self: @TContractState, proposal_id: u32, option_id: u8) -> u32;

    // Revokes a previously cast vote.
    fn revoke(self: @TContractState, proposal_id: u32) -> ();
}

#[dojo::contract]
mod vote_actions {
    use starknet::ContractAddress;
    use dojo_gov::models::proposal::{Proposal, ProposalStatus, ProposalTrait};
    use dojo_gov::models::global::{CONFIG_KEY, GlobalConfig};
    use dojo_gov::models::vote::Vote;
    use dojo_gov::models::option_summary::OptionSummary;
    use super::IVoteActions;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        VoteCast: VoteCast,
        VoteRevoked: VoteRevoked,
    }

    #[derive(Drop, starknet::Event)]
    struct VoteCast {
        proposal_id: u32,
        option_id: u8,
        vote: Vote,
    }

    #[derive(Drop, starknet::Event)]
    struct VoteRevoked {
        proposal_id: u32,
        option_id: u8,
        vote: Vote,
    }

    #[external(v0)]
    impl VoteActionsImpl of IVoteActions<ContractState> {
        fn create(self: @ContractState, proposal_id: u32, option_id: u8) -> u32 {
            let world = self.world_dispatcher.read();

            // Validate proposal and option.
            let mut proposal = get!(world, proposal_id, Proposal);
            proposal.refresh_status(world);
            assert(proposal.status == ProposalStatus::Voting, 'proposal not open');
            assert(option_id < 2, 'invalid option');

            let participant_address = starknet::get_caller_address();
            let mut cfg = get!(world, CONFIG_KEY, (GlobalConfig));
            cfg.vote_count += 1;
            let id = cfg.vote_count;
            let vote = Vote {
                id,
                participant_address,
                proposal_id,
                option_id,
                vote_weight: 1, // Fixed vote weight to 1 as per current requirements.
            };

            // Update proposal vote count and participant count.
            proposal.vote_count += vote.vote_weight;
            proposal.participant_count += 1;

            // Update option summary.
            let mut option_summary = get!(world, (proposal_id, option_id), OptionSummary);
            option_summary.participant_count += 1;
            option_summary.total_weight += vote.vote_weight;

            set!(world, (proposal, cfg, vote, option_summary));

            // Emit vote cast event.
            emit!(world, VoteCast { proposal_id, option_id, vote });

            // Return nothing as the create function does not need to return any value.
            id
        }

        fn revoke(self: @ContractState, proposal_id: u32) -> () { // TODO
        }
    }
}

#[cfg(test)]
mod vote_tests {
    use dojo_gov::actions::vote_actions::{IVoteActionsDispatcherTrait};
    use dojo_gov::models::global::{CONFIG_KEY, GlobalConfig};
    use dojo_gov::models::proposal::{Proposal, ProposalStatus, MetadataUrl};
    use dojo_gov::models::vote::{Vote};
    use dojo_gov::models::option_summary::{OptionSummary};
    use dojo_gov::tests::{init_world, DefaultWorld, create_init_proposal, add_block_number};
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};

    #[test]
    #[available_gas(3000000000)]
    fn test_create_vote() {
        let DefaultWorld{world, proposal_actions, vote_actions, caller, .. } = init_world();
        let proposal = create_init_proposal(world, proposal_actions);
        let option_id = 0; // Assuming the option we are voting for is 0

        // Create a vote for the proposal
        let vote_id = vote_actions.create(proposal.id, option_id);
        assert(vote_id > 0, 'vote id invalid');

        // Retrieve global configuration to validate vote count
        let cfg = get!(world, CONFIG_KEY, GlobalConfig);
        assert(cfg.vote_count == 1, 'global vote count wrong');

        // Retrieve proposal to validate vote and participant count
        let proposal = get!(world, (proposal.id), Proposal);
        assert(proposal.vote_count == 1, 'vote cnt wrong');
        assert(proposal.participant_count == 1, 'prtpt cnt wrong');

        // Retrieve option summary to validate participant count and total weight
        let option_summary = get!(world, (proposal.id, option_id), OptionSummary);
        assert(option_summary.participant_count == 1, 'opt prtpt cnt wrong');
        assert(option_summary.total_weight == 1, 'opt wt wrong');

        // Validate the created vote
        let vote = get!(world, (caller, proposal.id), Vote);
        assert(vote.proposal_id == proposal.id, 'vote prpsl id wrong');
        assert(vote.option_id == option_id, 'vote opt id wrong');
        assert(vote.participant_address == caller, 'vote prtcpt wrong');
        assert(vote.vote_weight == 1, 'vote wt wrong');
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic()]
    fn test_failed_vote_for_ended_proposal() {
        let DefaultWorld{world, proposal_actions, vote_actions, caller, .. } = init_world();
        let proposal = create_init_proposal(world, proposal_actions);
        add_block_number(10000000000);
        vote_actions.create(proposal.id, 0); // expect panic
    }
}
