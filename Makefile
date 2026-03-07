COMPLETION_DATA = data/claude-completion.json
COMPLETION_SCRIPT = completions/claude.bash
VERSION_FILE = data/VERSION

.PHONY: parse generate update validate test clean verify-generation

# Parse claude --help recursively, write JSON data
parse:
	python3 scripts/parse_help.py > $(COMPLETION_DATA)
	claude --version | awk '{print $$1}' > $(VERSION_FILE)

# Generate completion script from JSON data
generate: $(COMPLETION_DATA)
	python3 scripts/generate_completion.py

# Parse + generate (used by GHA update workflow)
update: parse generate

# Validate JSON and bash syntax
validate:
	python3 -c "import json; json.load(open('$(COMPLETION_DATA)'))"
	bash -n $(COMPLETION_SCRIPT)

# Run completion tests
test: validate
	bash scripts/test_completion.sh

# Verify generated script matches data (no manual edits)
verify-generation: generate
	git diff --exit-code $(COMPLETION_SCRIPT)

clean:
	rm -f $(COMPLETION_DATA) $(COMPLETION_SCRIPT) $(VERSION_FILE)
