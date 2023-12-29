import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { useEffect, useState } from "react";
import { useDojo } from "../DojoContext";
import "../css/create.css";

import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useForm } from "react-hook-form";

function Create() {
    const {
        setup: {
            systemCalls: { createProposal },
            components: { Proposal },
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

    useEffect(() => {

    }, []);

    const {
        register,
        handleSubmit,
        watch,
        formState: { errors },
    } = useForm();

    const onSubmit = (data) => {
    };



    return (
        <>
            <form onSubmit={handleSubmit(onSubmit)}>
                {/* register our input field with register function provided by the useForm hook */}
                <input placeholder="Enter your email" {...register("email")} />

                {/* basic validation in the second args */}
                <input
                    placeholder="Enter your password"

                    {...register("password", { required: true })}
                />
                {/* show error is the field encounters one  */}
                {errors.password && <p>Password is required</p>}

                <input type="submit" />
            </form>
        </>
    );
}

export default Create;
