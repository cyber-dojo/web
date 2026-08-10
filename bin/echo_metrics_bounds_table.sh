#!/usr/bin/env bash
set -Eeu

# Prints one row per bound in a metrics params file: the metric's name, the
# value the run reported, the comparison applied, the bound, and whether it
# holds. Green when it holds, red when it does not.
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
  local name value op bound holds
  while IFS=$'\t' read -r name value op bound holds; do
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
    printf '%s%34s | %6s  %s %6s |  %s%s\n' \
      "${colour}" "${name}" "${value}" "${op}" "${bound}" "${holds}" "${off}"
  done < <(echo_metrics_bounds_tsv "${report}" "${params}")
}

# True where ANSI colour reaches something that renders it: a terminal, or a CI
# log viewer. Not a redirect to a file, which would gain escape sequences.
colour_is_rendered()
{
  [ -t 1 ] || [ -n "${GITHUB_ACTIONS:-}" ]
}

# One tab-separated row per bound: name, reported value, comparison, bound,
# whether it holds.
#
# The params drive the walk, so each numeric leaf under max/min names a path to
# look up in the report. The comparison is the one actually applied - a max
# bound gives <=, a min bound gives >= - so the table cannot imply a tighter
# bound than the gate enforces. A metric the report lacks reads as absent and
# does not hold, matching the policy, which counts a missing metric as
# non-compliant rather than ignoring it.
echo_metrics_bounds_tsv()
{
  local -r report="${1}"
  local -r params="${2}"

  jq --raw-output --slurpfile report "${report}" '
    def bounds($op): [ paths(scalars) as $path
      | {path: $path, op: $op, bound: getpath($path)} ];

    $report[0] as $reported
    | (.max // {} | bounds("<=")) + (.min // {} | bounds(">="))
    | .[]
    # Bound to locals because the getpath below switches . to the report, where
    # .path and .bound would resolve against the wrong object.
    | .path as $path
    | .op as $op
    | .bound as $bound
    | ($reported | getpath($path)) as $value
    | [ ($path | join(".")),
        (if $value == null then "absent" else $value end),
        $op,
        $bound,
        (if $value == null then false
         elif $op == "<=" then $value <= $bound
         else $value >= $bound
         end | tostring)
      ]
    | @tsv
  ' "${params}"
}
