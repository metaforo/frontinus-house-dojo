use dojo::test_utils::spawn_test_world;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, syscalls::deploy_syscall};

use dojo_gov::models;
use dojo_gov::models::proposal::{Proposal, MetadataUrl};
use dojo_gov::actions::{
    proposal_actions::{
        proposal_actions, IProposalActionsDispatcher, IProposalActionsDispatcherImpl
    },
    vote_actions::{vote_actions, IVoteActionsDispatcher},
};

#[derive(Copy, Drop)]
struct DefaultWorld {
    world: IWorldDispatcher,
    caller: ContractAddress,
    proposal_actions: IProposalActionsDispatcher,
    vote_actions: IVoteActionsDispatcher,
}

fn init_world() -> DefaultWorld {
    let caller = starknet::contract_address_const::<0x0>();

    // define models
    let mut models = array![
        models::proposal::proposal::TEST_CLASS_HASH,
        models::vote::vote::TEST_CLASS_HASH,
        models::global::global_config::TEST_CLASS_HASH,
        models::option_summary::option_summary::TEST_CLASS_HASH,
    ];

    let world = spawn_test_world(models);

    // define actions
    let proposal_actions = IProposalActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', proposal_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let vote_actions = IVoteActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', vote_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    DefaultWorld { world, caller, proposal_actions, vote_actions }
}

fn create_init_proposal(
    world: IWorldDispatcher, proposal_actions: IProposalActionsDispatcher
) -> Proposal {
    let proposal_id = proposal_actions
        .create(
            3,
            12871283,
            MetadataUrl { part1: 'tGHSppCUlx5VokPISjRefDy8QPVuzj', part2: 'CIftsTYJzHP4w' },
        );
    get!(world, (proposal_id), Proposal)
}

fn add_block_number(number: u64) -> u64 {
    let mut block_number = starknet::get_block_info().unbox().block_number;
    block_number += number;
    starknet::testing::set_block_number(block_number);
    block_number
}
