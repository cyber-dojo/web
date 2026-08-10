#!/usr/bin/env bash
set -Eeu

# Prints one row per metric in a metrics params file: the metric's name, the
# value the run reported, the range that value must lie in, and whether it
# does. Green when it does, red when it does not.
#
# Purely informational. The decision stays with the rego policy the kosli CLI
# evaluates; this shows what that policy weighs, not what it concluded. The
# policy's result is an allow flag and a set of violation messages, so the CLI
# can only report the bounds that failed, never the ones that passed.
echo_metrics_bounds_table()
{
  local -r report="${1}"                     # data from a test run
  local -r params="${2}"                     # the bounds

  # Assigned here rather than in a helper: inside a command substitution stdout
  # is the substitution's pipe, so a tty test there would always say no.
  local green='' red='' off=''
  if colour_is_rendered; then
    green=$'\033[32m'
    red=$'\033[31m'
    off=$'\033[0m'
  fi

  local group previous_group='' colour
  local name value min max holds
  while IFS=$'\t' read -r name value min max holds; do
    # A blank line between the metric families, eg code and test. A flat report,
    # whose names have no family prefix, is one family and so stays unbroken.
    group=''
    if [[ "${name}" == *.* ]]; then
      group="${name%%.*}"
    fi
    if [ -n "${previous_group}" ] && [ "${group}" != "${previous_group}" ]; then
      echo
    fi
    previous_group="${group}"

    colour="${red}"
    if [ "${holds}" == 'true' ]; then
      colour="${green}"
    fi
    printf '%s%34s | %6s | %6s <= value <= %-6s |  %s%s\n' \
      "${colour}" "${name}" "${value}" "${min}" "${max}" "${holds}" "${off}"
  done < <(echo_metrics_bounds_tsv "${report}" "${params}")
}

# True where ANSI colour reaches something that renders it: a terminal, or a CI
# log viewer. Not a redirect to a file, which would gain escape sequences.
colour_is_rendered()
{
  [ -t 1 ] || [ -n "${GITHUB_ACTIONS:-}" ]
}

# One tab-separated row per metric: name, reported value, minimum, maximum,
# whether the value lies between them.
#
# The params drive the walk: every object under bounds naming both a min and a
# max is a range, and its path is the path to look up in the report. The
# comparison is the one the policy applies, so the table cannot imply a tighter
# bound than the gate enforces. A metric the report lacks reads as absent and
# does not hold, matching the policy, which counts a missing metric as
# non-compliant rather than ignoring it.
#
# A params entry naming only one side is left out rather than shown half
# applied. The policy reports it, and reports it as a breach.
echo_metrics_bounds_tsv()
{
  local -r report="${1}"
  local -r params="${2}"

  jq --raw-output --slurpfile report "${report}" '
    def ranges: [ paths(objects | has("min") and has("max")) as $path
      | {path: $path, min: getpath($path).min, max: getpath($path).max} ];

    $report[0] as $reported
    | (.bounds // {} | ranges)
    | .[]
    # Bound to locals because the getpath below switches . to the report, where
    # .path and .min would resolve against the wrong object.
    | .path as $path
    | .min as $min
    | .max as $max
    | ($reported | getpath($path)) as $value
    | [ ($path | join(".")),
        (if $value == null then "absent" else $value end),
        $min,
        $max,
        (if $value == null then false
         else ($value >= $min and $value <= $max)
         end | tostring)
      ]
    | @tsv
  ' "${params}"
}
