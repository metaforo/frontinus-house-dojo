import {setupNetwork, SetupNetworkResult} from "./setupNetwork";
import { Account } from "starknet";
import { Entity, getComponentValue } from "@dojoengine/recs";
import { uuid } from "@latticexyz/utils";
import {ClientComponents, createClientComponents} from "./createClientComponents";
import { Direction, updatePositionWithDirection } from "../utils";
import {
    getEntityIdFromKeys,
    getEvents,
    setComponentsFromEvents,
} from "@dojoengine/utils";
import { getSyncEntities } from "@dojoengine/react";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { execute, contractComponents }: SetupNetworkResult,
    { Vote }: ClientComponents
) {


    const voteProposal = async (signer: Account,id:number,option:number) => {
        try {
            const { transaction_hash } = await execute(
                signer,
                "vote_actions",
                "create",
                [
                    id,
                    option
                ]
            );


            setComponentsFromEvents(
                contractComponents,
                getEvents(
                    await signer.waitForTransaction(transaction_hash, {
                        retryInterval: 100,
                    })
                )
            );

            return transaction_hash;

        } catch (e) {
            console.log(e);
            // Vote.removeOverride(voteId);
        } finally {
            // Vote.removeOverride(voteId);
        }
    }




    const createProposal = async (signer: Account) => {
        try {
            const { transaction_hash } = await execute(
                signer,
                "proposal_actions",
                "create",
                [
                    10000,
                    1892406881151128685493026735573867696724574471638725433096995019971154,
                    1424063201423082855108164423542865,
                    0x152dcff993befafe5001975149d2c50bd9621da7cbaed74f68e7d5e54e65abc,
                    0x00898fecffccf25a55513abb0643e2dedf7043d3a29256a4c98e8cd59ebc219b,
                    88
                ]
            );

            setComponentsFromEvents(
                contractComponents,
                getEvents(
                    await signer.waitForTransaction(transaction_hash, {
                        retryInterval: 100,
                    })
                )
            );

            return transaction_hash;

        } catch (e) {
            console.log(e);
            // Vote.removeOverride(voteId);
        } finally {
            // Vote.removeOverride(voteId);
        }
    }



    return {
        createProposal,
        voteProposal
    };
}
