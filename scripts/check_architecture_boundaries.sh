#!/usr/bin/env bash
# Guards the one architecture boundary this repo has already been bitten by
# once (see audit Finding #0a): the presentation layer must never import
# isar_community directly — it must go through a repository/use case in
# domain/infrastructure instead.
#
# This is intentionally a plain grep, not a custom_lint/import_lint package:
# it's trivial to verify by inspection, has zero new dependencies, and
# covers the one concrete violation this codebase has actually hit twice.
# If the project outgrows this, replace it with a proper import_lint /
# custom_lint rule — but don't add unverified lint-package config just to
# look thorough.
#
# Usage: ./scripts/check_architecture_boundaries.sh
# Exit code 0 = clean, 1 = violation(s) found (prints each offending file).

set -uo pipefail

violations=$(grep -rl "package:isar_community" lib/features/*/presentation/ --include="*.dart" 2>/dev/null | grep -v "\.g\.dart")

if [ -n "$violations" ]; then
  echo "❌ Architecture boundary violation: presentation/ must not import isar_community directly."
  echo "   Route reads/writes through a domain repository interface + use case instead."
  echo "   Offending file(s):"
  echo "$violations" | sed 's/^/     /'
  exit 1
fi

echo "✅ No presentation -> isar_community imports found."
exit 0
