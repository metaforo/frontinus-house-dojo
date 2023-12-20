use dojo::test_utils::spawn_test_world;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, syscalls::deploy_syscall};

use dojo_gov::models;
use dojo_gov::actions::{proposal_actions::{proposal_actions, IProposalActionsDispatcher},};

#[derive(Copy, Drop)]
struct DefaultWorld {
    world: IWorldDispatcher,
    caller: ContractAddress,
    proposal_actions: IProposalActionsDispatcher,
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

    DefaultWorld { world, caller, proposal_actions }
}
