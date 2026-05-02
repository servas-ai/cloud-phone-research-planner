# Justfile — common development commands
# https://github.com/casey/just
#
# Use:  just <task>
# List: just --list

# Default target
default:
    @just --list

# === Validation ===

# Run Gemini-CLI Round-N validation (verified working pattern)
validate-gemini PROMPT_FILE="prompts/03-validate-round.md":
    GEMINI_CLI_TRUST_WORKSPACE=true gemini -p "$(cat {{PROMPT_FILE}})" \
      --skip-trust --approval-mode plan -m gemini-3-pro-preview

# Validate probe inventory schema
validate-probes:
    @python -c "import yaml,sys; from pathlib import Path; \
inv=yaml.safe_load(Path('probes/inventory.yml').read_text()); \
ranks=[p['rank'] for p in inv['probes']]; \
assert len(ranks)==len(set(ranks)), 'duplicate ranks'; \
print(f'OK: {len(inv[\"probes\"])} probes, ranks {min(ranks)}-{max(ranks)}')"

# Lint markdown
lint-md:
    npx -y markdownlint-cli2 "**/*.md" "#code-quality-skills" "#audit-reports" "#node_modules" || true

# Lint YAML
lint-yaml:
    yamllint -d '{extends: relaxed, rules: {line-length: disable}}' probes/ stack/ .github/ || true

# Run all linters
lint: lint-md lint-yaml validate-probes

# === Repository introspection ===

# Show open findings count
findings-count:
    @grep -cE "^### F[0-9]+" plans/05-validation-feedback.md plans/07-round-2-feedback.md 2>/dev/null || echo "0"

# Show resolved findings (per Round-2)
findings-resolved:
    @grep -A1 "Resolved by" plans/07-round-2-feedback.md | head -20

# Show probe inventory summary
probes-summary:
    @python -c "import yaml; from pathlib import Path; \
inv=yaml.safe_load(Path('probes/inventory.yml').read_text()); \
from collections import Counter; \
cats=Counter(p['category'] for p in inv['probes']); \
[print(f'{c:15} {n}') for c,n in cats.most_common()]"

# === Repo hygiene ===

# Show git status with planner-specific filters
status:
    @git status --short | grep -vE "(audit-reports|code-quality-skills|.cqc)" || echo "Clean"

# Show recent commits
log N="10":
    @git log --oneline -{{N}}
