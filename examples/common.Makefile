
RULES_DIR = ../../rules
SCRIPTS_DIR = ../../scripts

YW_EXTRACT_FACTS = facts/yw_extract_facts.P
YW_MODEL_FACTS = facts/yw_model_facts.P
YW_FACTS = $(YW_EXTRACT_FACTS) $(YW_MODEL_FACTS)
YW_VIEWS = yw_views.P
YW_MODEL_OPTIONS = -c extract.language=python \
                   -c extract.factsfile=$(YW_EXTRACT_FACTS) \
                   -c model.factsfile=$(YW_MODEL_FACTS) \
                   -c query.engine=xsb

NW_TRACER_DEPTH = 3
NW_FACTS = facts/nw_facts.P
NW_VIEWS = nw_views.P

YW_NW_VIEWS = yw_nw_views.P

RUN_STDOUT = run_outputs.txt
RUN_OUTPUTS = $(RUN_STDOUT)

ifndef SCRIPT_RUN_CMD
SCRIPT_RUN_CMD = $(WORKFLOW_SCRIPT)
endif


RULES = $(RULES_DIR)/nw_views.P $(RULES_DIR)/yw_views.P $(RULES_DIR)/yw_nw_views.P
QUERY_SCRIPT = query.sh
QUERY_OUTPUTS = query_outputs.txt

YW_DATA_GRAPH = yw_data_graph
YW_PROCESS_GRAPH = yw_process_graph
YW_COMBINED_GRAPH = yw_combined_graph
YW_PROSPECTIVE_LINEAGE_GRAPH = yw_prospective_lineage
YW_GRAPHS = $(YW_DATA_GRAPH).gv \
            $(YW_PROCESS_GRAPH).gv \
	        $(YW_COMBINED_GRAPH).gv \
	        $(YW_PROSPECTIVE_LINEAGE_GRAPH).gv

ifdef NW_FILTERED_LINEAGE
NW_FILTERED_LINEAGE_GRAPH = nw_filtered_lineage_graph
NW_GRAPHS = $(NW_FILTERED_LINEAGE_GRAPH).gv
endif

YW_NW_RETROSPECTIVE_LINEAGE_GRAPH = yw_nw_retrospective_lineage
YW_NW_GRAPHS = $(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).gv

GRAPHS = $(YW_GRAPHS) $(NW_GRAPHS) $(YW_NW_GRAPHS)
PNGS = $(GRAPHS:.gv=.png)
PDFS = $(GRAPHS:.gv=.pdf)

all: $(QUERY_OUTPUTS) $(GRAPHS) $(PNGS) $(PDFS)
run: $(RUN_OUTPUTS)
yw: $(YW_FACTS) $(YW_VIEWS) $(YW_GRAPHS)
nw: $(NW_FACTS) $(NW_VIEWS) $(NW_GRAPHS)
ywnw: $(YW_NW_VIEWS) $(YW_NW_GRAPHS)
query: $(QUERY_OUTPUTS)
graph: $(GRAPHS)
png: $(PNGS)
pdf: $(PDFS)

.SUFFIXES:
.SUFFIXES: .gv .pdf .png

.gv.pdf:
	dot -Tpdf $*.gv -o $*.pdf

.gv.png:
	dot -Tpng $*.gv -o $*.png

ifdef DATA
RETROSPECTIVE_LINEAGE_DATA = $(DATA)
PROSPECTIVE_LINEAGE_DATA = $(DATA)
.PHONY: $(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).gv \
        $(YW_PROSPECTIVE_LINEAGE_GRAPH).gv
endif

ifdef VALUE
RETROSPECTIVE_LINEAGE_VALUE= "$(VALUE)"
.PHONY: $(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).gv \
		$(NW_FILTERED_LINEAGE_GRAPH).gv
endif

$(YW_FACTS): $(WORKFLOW_SCRIPT)
ifdef YW_JAR
	mkdir -p facts
	java -jar $(YW_JAR) model $(WORKFLOW_SCRIPT) $(YW_MODEL_OPTIONS)
else
	$(error Must set YW_JAR environment variable to path to YesWorkflow jar)
endif

$(YW_VIEWS): $(YW_FACTS)
	bash $(SCRIPTS_DIR)/materialize_yw_views.sh > $(YW_VIEWS)

$(RUN_OUTPUTS): $(WORKFLOW_SCRIPT)
	now run -e Tracer -d $(NW_TRACER_DEPTH) $(SCRIPT_RUN_CMD) > $(RUN_STDOUT)
	${POST_RUN_CMD}

$(NW_FACTS): $(RUN_OUTPUTS)
	mkdir -p facts
	now export -t -m dependency | grep -v 'environment(' > $(NW_FACTS)

$(NW_VIEWS): $(NW_FACTS)
	bash $(SCRIPTS_DIR)/materialize_nw_views.sh > $(NW_VIEWS)

$(YW_NW_VIEWS): $(YW_VIEWS) $(NW_VIEWS)
	bash $(SCRIPTS_DIR)/materialize_yw_nw_views.sh > $(YW_NW_VIEWS)

$(YW_DATA_GRAPH).gv: $(YW_VIEWS)
	bash $(SCRIPTS_DIR)/$(YW_DATA_GRAPH).sh > $(YW_DATA_GRAPH).gv

$(YW_PROCESS_GRAPH).gv: $(YW_VIEWS)
	bash $(SCRIPTS_DIR)/$(YW_PROCESS_GRAPH).sh > $(YW_PROCESS_GRAPH).gv

$(YW_COMBINED_GRAPH).gv: $(YW_VIEWS)
	bash $(SCRIPTS_DIR)/$(YW_COMBINED_GRAPH).sh > $(YW_COMBINED_GRAPH).gv

$(YW_PROSPECTIVE_LINEAGE_GRAPH).gv: $(YW_VIEWS)
	bash $(SCRIPTS_DIR)/$(YW_PROSPECTIVE_LINEAGE_GRAPH).sh \
		$(PROSPECTIVE_LINEAGE_DATA) \
		> $(YW_PROSPECTIVE_LINEAGE_GRAPH).gv

$(NW_FILTERED_LINEAGE_GRAPH).gv: $(NW_FACTS)
	now helper df_style.py
	now dataflow -v 55 -f $(RETROSPECTIVE_LINEAGE_VALUE) -m simulation | python df_style.py -d BT -e > nw_filtered_lineage_graph.gv

$(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).gv : $(YW_NW_VIEWS)
	bash $(SCRIPTS_DIR)/$(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).sh \
		$(RETROSPECTIVE_LINEAGE_DATA) $(RETROSPECTIVE_LINEAGE_VALUE) \
		> $(YW_NW_RETROSPECTIVE_LINEAGE_GRAPH).gv

$(QUERY_OUTPUTS): $(QUERY_SCRIPT) $(YW_VIEWS) $(NW_VIEWS) $(YW_NW_VIEWS) $(RULES)
	bash $(QUERY_SCRIPT) > $(QUERY_OUTPUTS)

clean:
	rm -rf facts .noworkflow *.xwam *.gv *.png *.pdf *.P *.txt  df_style.py $(RULES_DIR)/*.xwam

repl: $(YW_NW_VIEWS)
	expect $(RULES_DIR)/start_xsb.exp
