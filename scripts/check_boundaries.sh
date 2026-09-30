#!/usr/bin/env bash
#
# Machine-enforced Clean Architecture import boundaries.
#
# `import_lint` 2.x cannot be used due to analyzer version pinning by isar generator.
# These ripgrep checks enforce architectural rules with zero dependencies
# and fail the pipeline (non-zero exit) on any violation.
#
# Rules:
#   1. Domain layer imports no Flutter, Riverpod, or Infrastructure-layer code.
#   2. Presentation layer imports no Isar directly.

set -euo pipefail

FAIL=0
DOMAIN=$(find lib/features -maxdepth 2 -type d -name "domain")
PRESENTATION="$(find lib/features -maxdepth 2 -type d -name "presentation") lib/main.dart"

check() {
  local description="$1"
  shift
  if "$@" | grep .; then
    echo "❌ [BOUNDARY] $description" >&2
    FAIL=1
  fi
}

# Rule 1a: no Flutter imports in domain.
check "Flutter import inside domain layer." \
  rg -n --glob '!*.g.dart' '^import .+package:flutter/' $DOMAIN

# Rule 1b: no Riverpod imports in domain.
check "Riverpod import inside domain layer." \
  rg -n '^import .+package:(flutter_riverpod|riverpod|riverpod_annotation)/' $DOMAIN

# Rule 1c: no Infrastructure-layer imports in domain.
check "Infrastructure-layer import inside domain layer." \
  rg -n '^import .+/infrastructure/' $DOMAIN

# Rule 2: no Isar imports in presentation.
check "Isar import inside presentation layer." \
  rg -n --glob '!*.g.dart' '^import .+package:isar_community/' $PRESENTATION

if [ "$FAIL" -ne 0 ]; then
  echo "❌ [BOUNDARY] Architecture boundary check failed." >&2
  exit 1
fi
echo "✅ [BOUNDARY] All import boundaries hold."
