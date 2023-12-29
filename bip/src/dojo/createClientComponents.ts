import { overridableComponent } from "@dojoengine/recs";
import { SetupNetworkResult } from "./setupNetwork";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({
    contractComponents,
}: SetupNetworkResult) {
    return {
        ...contractComponents,
        GlobalConfig: overridableComponent(contractComponents.GlobalConfig),
        OptionSummary: overridableComponent(contractComponents.OptionSummary),
        Proposal: overridableComponent(contractComponents.Proposal),
        Vote: overridableComponent(contractComponents.Vote),
    };
}
