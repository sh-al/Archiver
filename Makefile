NODE=archive

APP=archive_app
ERL=@ERL_LIBS=deps erl +K true -pa ebin
RE_LOG_MAXSIZE=10000000
RE_DIR=log/run_erl/
REBAR=@./rebar

.PHONY: all deps test

all:
	$(REBAR) compile skip_deps=true

deps:
	$(REBAR) get-deps compile

run:
	erl -pa ebin -pa deps/*/ebin +K true -sname $(NODE) -eval "application:start(archive)"

run_dep:
	$(ERL) -s $(APP) -sname $(NODE)

# todo start one instance only
start:
	@echo -n "Starting ARCHIVE Service.."
	@mkdir -p $(RE_DIR)
	@run_erl -daemon $(RE_DIR) $(RE_DIR) "exec make run"
	@echo "ok"

stop:
	@echo -n "Stopping ARCHIVE Service.."
	@echo "init:stop()." | to_erl $(RE_DIR) 2>/dev/null
	@echo "ok"