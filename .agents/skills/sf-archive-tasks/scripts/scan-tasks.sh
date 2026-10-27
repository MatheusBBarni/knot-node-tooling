#!/usr/bin/env bash
# Classify Spec Finder task packets without modifying them.
# Usage: scan-tasks.sh [tasks-dir] [report-only] [--slug TASK_SLUG]
# The optional slug limits every classifier record to one active packet.
set -u

TASKS_DIR=".spec-finder/tasks"
TARGET_SLUG=""
REPORT_ONLY=0
POSITIONAL=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --slug)
      if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
        echo "error: --slug requires one task slug" >&2
        exit 2
      fi
      if [ -n "$TARGET_SLUG" ]; then
        echo "error: --slug may be supplied only once" >&2
        exit 2
      fi
      TARGET_SLUG="$2"
      shift 2
      ;;
    report-only)
      if [ "$REPORT_ONLY" -eq 1 ]; then
        echo "error: report-only may be supplied only once" >&2
        exit 2
      fi
      REPORT_ONLY=1
      shift
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      exit 2
      ;;
    *)
      if [ "$POSITIONAL" -eq 1 ]; then
        echo "error: expected one tasks directory" >&2
        exit 2
      fi
      TASKS_DIR="$1"
      POSITIONAL=1
      shift
      ;;
  esac
done

if [ -n "$TARGET_SLUG" ] && [[ ! "$TARGET_SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: invalid task slug: $TARGET_SLUG" >&2
  exit 2
fi

if [ ! -d "$TASKS_DIR" ]; then
  echo "error: tasks dir not found: $TASKS_DIR" >&2
  exit 2
fi

if [ -n "$TARGET_SLUG" ] && [ ! -d "$TASKS_DIR/$TARGET_SLUG" ]; then
  echo "error: target packet not found: $TARGET_SLUG" >&2
  exit 4
fi

status_of() {
  grep -m1 -iE '^status:[[:space:]]*' "$1" 2>/dev/null \
    | sed -E 's/^[Ss]tatus:[[:space:]]*//' \
    | tr '[:upper:]' '[:lower:]' \
    | tr -d '[:space:]'
}

frontmatter_checkpoint_field_of() {
  field="$2"
  awk -v field="$field" '
    BEGIN { frontmatter = 0; checkpoint = 0 }
    NR == 1 && $0 == "---" { frontmatter = 1; next }
    frontmatter && $0 == "---" { exit }
    !frontmatter { next }

    # Accept the dotted form as well as the block form so report-only
    # classification remains tolerant of equivalent frontmatter notation.
    $0 ~ ("^[[:space:]]*checkpoint[.]" field ":[[:space:]]*") {
      value = $0
      sub("^[[:space:]]*checkpoint[.]" field ":[[:space:]]*", "", value)
      print value
      exit
    }

    $0 ~ /^[[:space:]]*checkpoint:[[:space:]]*$/ { checkpoint = 1; next }
    checkpoint && $0 !~ /^[[:space:]]/ { checkpoint = 0 }
    checkpoint && $0 ~ ("^[[:space:]]+" field ":[[:space:]]*") {
      value = $0
      sub("^[[:space:]]+" field ":[[:space:]]*", "", value)
      print value
      exit
    }
  ' "$1" | sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//; s/^['\"]//; s/['\"]$//"
}

checkpoint_state_of() {
  frontmatter_checkpoint_field_of "$1" state
}

checkpoint_error_of() {
  frontmatter_checkpoint_field_of "$1" error
}

printf '%-32s %-12s %-9s %-9s %-14s %s\n' "FOLDER" "VERDICT" "DONE" "TRACKED" "INDEX" "UNCHECKED"
printf '%-32s %-12s %-9s %-9s %-14s %s\n' "------" "-------" "----" "-------" "-----" "---------"

verdicts=""
found=0
if [ -n "$TARGET_SLUG" ]; then
  directories=("$TASKS_DIR/$TARGET_SLUG/")
else
  directories=("$TASKS_DIR"/*/)
fi

for directory in "${directories[@]}"; do
  [ -d "$directory" ] || continue
  found=1
  name="$(basename "$directory")"
  total=0
  completed=0
  other=0
  statuses=""
  blocked=0

  for task in "$directory"task_*.md; do
    [ -f "$task" ] || continue
    total=$((total + 1))
    status="$(status_of "$task")"
    checkpoint_state="$(checkpoint_state_of "$task")"
    if [ "$status" = "completed" ]; then
      completed=$((completed + 1))
      if [ "$checkpoint_state" = "blocked" ]; then
        blocked=$((blocked + 1))
        blocker="$(checkpoint_error_of "$task" | tr '\r\n\t' '   ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
        statuses="${statuses}checkpoint-blocked${blocker:+($blocker)},"
      fi
    else
      other=$((other + 1))
      statuses="${statuses}${status:-missing},"
    fi
  done

  if [ "$total" -eq 0 ]; then
    verdict="EARLY-STAGE"
  elif [ "$completed" -eq "$total" ] && [ "$blocked" -eq 0 ]; then
    verdict="DONE"
  else
    verdict="REMAINING"
  fi

  if [ -n "$(git ls-files "$directory" 2>/dev/null | head -1)" ]; then
    tracked="tracked"
  else
    tracked="untracked"
  fi

  index="noIndex"
  index_file="${directory}_tasks.md"
  if [ -f "$index_file" ]; then
    if grep -qiE '^\|.*status.*\|$' "$index_file" 2>/dev/null; then
      index_completed="$(grep -ciE '\|[[:space:]]*completed[[:space:]]*\|' "$index_file" 2>/dev/null)"
      if [ "$index_completed" = "$completed" ]; then
        index="indexMatch"
      else
        index="indexDrift($index_completed)"
      fi
    else
      index="indexNoStatus"
    fi
  fi

  unchecked="$(grep -rhE '^[[:space:]]*- \[ \]' "$directory" 2>/dev/null | wc -l | tr -d '[:space:]')"
  printf '%-32s %-12s %-9s %-9s %-14s %s\n' "$name" "$verdict" "$completed/$total" "$tracked" "$index" "$unchecked"
  verdicts="${verdicts}VERDICT	${name}	${verdict}	${completed}/${total}	${tracked}	${index}	${unchecked}	${statuses%,}
"
done

if [ "$found" -eq 0 ]; then
  echo "error: no task packets found in $TASKS_DIR" >&2
  exit 3
fi

echo
printf '%b' "$verdicts"
