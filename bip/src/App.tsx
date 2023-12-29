import {useComponentValue, useEntityQuery} from "@dojoengine/react";
import {Entity, getComponentValueStrict,getComponentValue, Has} from "@dojoengine/recs";
import React, {useEffect, useState} from "react";
import "./App.css";
import {useDojo} from "./DojoContext";
import {getEntityIdFromKeys} from "@dojoengine/utils";

function App() {


    // useEffect(() => {
    // }, []);

    const {
        setup: {
            systemCalls: { createProposal,voteProposal },
            components: { Proposal,OptionSummary },
        },
        account: {
            create,
            list,
            select,
            account,
            isDeploying,
            clear,
            copyToClipboard,
            applyFromClipboard,
        },
    } = useDojo();




    const [clipboardStatus, setClipboardStatus] = useState({
        message: "",
        isError: false,
    });


    const [proposals,setProposals] = useState([] as any );
    const [option,setOption] = useState(0);
    const [loading,setLoading] = useState(false);
    const [voteHash,setVoteHash] = useState("");
    const [voteId,setVoteId] = useState(0);
    const [hash,setHash] = useState("");

    // entity id we are syncing


    // get current component values

    // const position = useComponentValue(Position, entityId);
    // const moves = useComponentValue(Moves, entityId);



    // const t = useEntityQuery([Has(Proposal)]);
    // console.log(t[0]);

    // const outpost = getComponentValueStrict(Proposal, t[0]);
    // console.log(outpost);

    // const entities = getEntities(network,Proposal);

    const handleRestoreBurners = async () => {
        try {
            await applyFromClipboard();
            setClipboardStatus({
                message: "Burners restored successfully!",
                isError: false,
            });
        } catch (error) {
            setClipboardStatus({
                message: `Failed to restore burners from clipboard`,
                isError: true,
            });
        }
    };




    const handleVote = async (account:any,id:any) => {
        try {
            const hash = await voteProposal(account,id,option);
            setVoteHash(hash);
            setVoteId(id);
        } catch (error) {

        }
    };

    const scrollToBottom = () => {
        window.scrollTo(0, document.body.scrollHeight);
    };


    const getVote = (entityId:any) => {
        try {
            // console.log(value);
            return useComponentValue(OptionSummary, entityId);

        } catch (error) {
            return null;
        }
    };

    const handleCreate = async (account:any) => {
        try {

            setHash("");
            setLoading(true);
            const hash = await createProposal(account);
            setHash(hash);
            setLoading(false);
            scrollToBottom();

            // window.location.reload();
        } catch (error) {
            setLoading(false)
        }
    };


    const proposalEntities = useEntityQuery([Has(Proposal)]);

    return (
        <>
            <button onClick={create}>
                {isDeploying ? "deploying burner" : "create burner"}
            </button>
            {list().length > 0 && (
                <button onClick={async () => await copyToClipboard()}>
                    Save Burners to Clipboard
                </button>
            )}
            <button onClick={handleRestoreBurners}>
                Restore Burners from Clipboard
            </button>
            {clipboardStatus.message && (
                <div className={clipboardStatus.isError ? "error" : "success"}>
                    {clipboardStatus.message}
                </div>
            )}

            <div className="card">
                select signer:{" "}
                <select
                    value={account ? account.address : ""}
                    onChange={(e) => select(e.target.value)}
                >
                    {list().map((account, index) => {
                        return (
                            <option value={account.address} key={index}>
                                {account.address}
                            </option>
                        );
                    })}
                </select>
                <div>
                    <button onClick={() => clear()}>Clear burners</button>
                </div>
            </div>

            <div className="card">
                <button onClick={() => handleCreate(account)}>{!loading ? 'Create Proposal' : 'Creating' }</button>
            </div>
            {
                hash &&
                (<div className="card">
                    create hash : {hash}
                </div>)
            }



            <div className="list">
                {
                    proposalEntities.length > 0 && proposalEntities.map(function (value, key) {

                        const tmp = getComponentValueStrict(Proposal, value);

                        console.log(tmp);



                        const yesEntityId = getEntityIdFromKeys([BigInt(tmp.id),BigInt(0)]) as Entity;
                        const noEntityId = getEntityIdFromKeys([BigInt(tmp.id),BigInt(1)]) as Entity;


                         const  yesVote = getComponentValue(OptionSummary,yesEntityId);
                         const  noVote = getComponentValue(OptionSummary,noEntityId);


                        return (
                            <div className="block" key={key} id={"proposal-"+tmp.id}>
                                <div className="header">
                                    <div className="left">ID: {tmp.id}</div>
                                    {/*<div className="right">Status: {tmp.status}</div>*/}
                                </div>
                                <div className="body">
                                    <div className="line">Title</div>
                                    <div className="line">Content</div>
                                    <div className="line">
                                        <div className="left">Participant Count: {tmp.participant_count}</div>
                                        <div className="right">Vote Count: {tmp.vote_count}</div>
                                    </div>
                                    <div className="line vote">
                                            <div className="cursor mr-5"><input type="radio" name={"vote"+tmp.id} value={1} onClick={()=>setOption(0)} />Yes({yesVote?yesVote.total_weight:0})</div>
                                            <div className="cursor"><input type="radio" name={"vote"+tmp.id} value={0} onClick={()=>setOption(1)}/>No({noVote?noVote.total_weight:0})</div>
                                    </div>
                                    <div className="line">
                                        <button onClick={async () => await handleVote(account,tmp.id)}>Vote</button>
                                        {
                                            (voteId == tmp.id && voteHash ) &&
                                            (<div className="voteHash">{voteHash}</div>)
                                        }
                                    </div>

                                </div>
                            </div>
                        );
                    })
                }


            </div>

        </>
    );
}

export default App;
