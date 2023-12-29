# RealmGovernance Hub: Empowering Community Consensus in the Game of Eternum

## Introduction

Built on the robust architecture of Frontinus House and coded in DOJO, our world governance module, RealmGovernance Hub, revolutionizes the altering of attributes and parameters in the Game of Eternum. Operating fully on-chain, this module establishes a democratic process where community members can propose alterations by submitting a BIP on Frontinus House.

Upon proposal submission, a community-wide vote ensues, utilizing on-chain voting mechanisms that involve the burning of gas fees for added transparency. Once the vote concludes, the game parameters are seamlessly adjusted in accordance with the passed BIP consensus. Join us in shaping the future of the Game of Eternum through decentralized and community-driven governance.

## Project Architecture

This section outlines the primary components of RealmGovernance Hub and their interactions.

### Smart Contracts

#### `proposal_actions` Contract

Facilitates the creation and execution of proposals.

- `create`: Initializes a new proposal, specifying end block, description, and the contract address and details that will be invoked upon successful voting.
- `execute`: Carries out the proposal if it has been approved and not yet enacted.

#### `vote_actions` Contract

Manages the voting process for proposals.

- `create`: Submits a vote for a given `proposal_id` using an `option_id` (0 for yes, 1 for no, with the possibility of additional options in the future).
- `revoke`: Withdraws an already cast vote.

### Interfaces

```cairo
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

trait IVoteActions<TContractState> {
    fn create(self: @TContractState, proposal_id: u32, option_id: u8) -> u32;

    fn revoke(self: @TContractState, proposal_id: u32) -> ();
}
```

## State Management

In RealmGovernance Hub, managing the state of proposals is crucial to the governance process. The `proposal_actions` contract maintains the lifecycle of each proposal through various statuses, reflecting its current state within the governance framework. The `vote_actions` contract, on the other hand, does not maintain complex state beyond recording individual votes.

### Proposal States

The lifecycle of a proposal is represented by the following states, as defined in the `ProposalStatus` module:

```cairo
mod ProposalStatus {
    const Undefined: u32 = 0;
    const Voting: u32 = 1; // Proposal is in the voting period.
    const Passed: u32 = 2; // Voting period ended, votes passed, proposal awaiting execution.
    const Rejected: u32 = 3; // Voting period ended, votes did not pass, proposal cannot be executed.
    const Executed: u32 = 4; // Proposal has been executed successfully.
}
```

- `Undefined`: This is the initial state of a proposal before it has been officially created or recognized by the system.
- `Voting`: Once a proposal has been created, it enters the `Voting` state. During this period, participants can cast their votes. The end block specified in the proposal determines when the voting period ends.
- `Passed`: If a proposal receives enough affirmative votes by the end of the voting period, it transitions to the `Passed` state. In this state, the proposal is approved but not yet actioned, awaiting the execution of its associated contract call.
- `Rejected`: Should the proposal fail to garner sufficient support, it is marked as `Rejected`, indicating that it did not pass the voting threshold and thus cannot be executed.
- `Executed`: After a successful execution of the proposal's intended actions, the state is set to `Executed`. This final state signifies the completion of the proposal's lifecycle.

The transition between these states is governed by the logic within the smart contracts, which checks the number of votes, compares them against the required thresholds, and observes the block height to determine the timing of state changes.

By managing the state of each proposal transparently and systematically, RealmGovernance Hub ensures a clear and auditable governance process that aligns with the principles of decentralized decision-making.


## Contact

Endpoint : [slot](https://api.cartridge.gg/x/dojo-gov-27/katana)
World Adderss: 0x2e0b9ee68542d766af0afed2bf9d4e197f48d3d20281fbdf3e910c2c5b30b8b
Proposal Actions: 0xdaf3b44814ca688d56cc92e76b180bb7ea56a79303161810b485c42c14b0bc
Vote Actions:  0x33f21150bcc5778ba957daffb13ed3131e9e0dcd58103a23dfac1c5b9f9d487

Online Demo : https://bip-zhoupufelix-felixs-projects-cfb2e9f3.vercel.app/
