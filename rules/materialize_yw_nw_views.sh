#!/usr/bin/env bash -l
#
# ./run_queries.sh &> run_queries.txt

xsb --quietload --noprompt --nofeedback --nobanner << END_XSB_STDIN

[yw_views].
[nw_views].
['../../rules/general_rules'].
['../../rules/yw_nw_rules'].
['../../rules/yw_nw_views'].

set_prolog_flag(unknown, fail).

rule_banner('nw_activation_from_yw_step(ActivationId, FunctionName, StepId, StepName, ActivationLine).').
printall(nw_activation_from_yw_step(_,_,_,_,_)).

rule_banner('nw_variable_for_yw_in_port(VariableId, VariableName, VariableValue, DataId, DataName, PortId, PortName, StepId, StepName).').
printall(nw_variable_for_yw_in_port(_,_,_,_,_,_,_,_,_)).

rule_banner('nw_variable_for_yw_out_port(VariableId, VariableName, VariableValue, DataId, DataName, PortId, PortName, StepId, StepName).').
printall(nw_variable_for_yw_out_port(_,_,_,_,_,_,_,_,_)).

END_XSB_STDIN
