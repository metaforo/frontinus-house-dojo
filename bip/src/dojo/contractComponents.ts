/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export function defineContractComponents(world: World) {
  return {
	  GlobalConfig: (() => {
	    return defineComponent(
	      world,
	      { id: RecsType.Number, proposal_count: RecsType.Number, vote_count: RecsType.Number },
	      {
	        metadata: {
	          name: "GlobalConfig",
	          types: ["u32","u32","u32"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  OptionSummary: (() => {
	    return defineComponent(
	      world,
	      { proposal_id: RecsType.Number, option_id: RecsType.Number, participant_count: RecsType.Number, total_weight: RecsType.Number },
	      {
	        metadata: {
	          name: "OptionSummary",
	          types: ["u32","u8","u32","u32"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Proposal: (() => {
	    return defineComponent(
	      world,
	      { id: RecsType.Number, proposer_address: RecsType.BigInt, metadata_url: { part1: RecsType.BigInt, part2: RecsType.BigInt }, participant_count: RecsType.Number, vote_count: RecsType.Number, start_block: RecsType.Number, end_block: RecsType.Number, status: RecsType.Number, contract_addr: RecsType.BigInt, entrypoint: RecsType.BigInt, call_data: RecsType.BigInt },
	      {
	        metadata: {
	          name: "Proposal",
	          types: ["u32","contractaddress","felt252","felt252","u32","u32","u64","u64","u32","contractaddress","felt252","felt252"],
	          customTypes: ["MetadataUrl"],
	        },
	      }
	    );
	  })(),
	  Vote: (() => {
	    return defineComponent(
	      world,
	      { participant_address: RecsType.BigInt, proposal_id: RecsType.Number, id: RecsType.Number, option_id: RecsType.Number, vote_weight: RecsType.Number },
	      {
	        metadata: {
	          name: "Vote",
	          types: ["contractaddress","u32","u32","u8","u32"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
  };
}
