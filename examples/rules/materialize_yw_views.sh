#!/usr/bin/env bash -l
#
# ./run_queries.sh &> run_queries.txt

xsb --quietload --noprompt --nofeedback --nobanner << END_XSB_STDIN

[yw_extract_facts].
[yw_model_facts].
['../rules/general_rules'].
['../rules/yw_view_rules'].

writeln('% FACT: yw_workflow_script(WorkflowId, WorkflowName, SourceId, SourceFile).').
printall(yw_workflow_script(_,_,_,_)).
writeln('').

writeln('% FACT: yw_source_file(SourceId, SourceFile).').
printall(yw_source_file(_,_)).
writeln('').

writeln('% FACT: yw_workflow(WorkflowId, WorkflowName, ParentWorkflowId, SourceId, BeginLine, EndLine).').
printall(yw_workflow(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_workflow_step(StepId, StepName, ParentWorkflowId, SourceId, BeginLine, EndLine).').
printall(yw_workflow_step(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_function(FunctionId, FunctionName, ParentWorkflowId, SourceId, BeginLine, EndLine).').
printall(yw_function(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_in_port(ProgramId, ProgramName, PortId, PortName, DataId, DataName).').
printall(yw_in_port(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_out_port(ProgramId, ProgramName, PortId, PortName, DataId, DataName).').
printall(yw_out_port(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_inflow(WorkflowId, WorkflowName, DataId, DataName, ProgramId, ProgramName).').
printall(yw_inflow(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_flow(SourceProgramId, SourceProgramName, DataId, DataName, SinkProgramId, SinkProgramName).').
printall(yw_flow(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_outflow(ProgramId, ProgramName,ProgramDataId, DataName, WorkflowId, WorkflowName).').
printall(yw_outflow(_,_,_,_,_,_)).
writeln('').

writeln('% FACT: yw_qualified_name(EntityType, Name, QualifiedName).').
printall(yw_qualified_name(_,_,_)).
writeln('').

writeln('% FACT: yw_description(EntityType, Id, Description).').
printall(yw_description(_,_,_,_)).
writeln('').

END_XSB_STDIN