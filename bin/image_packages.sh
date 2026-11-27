#!/usr/bin/env bash
set -Eeu

# An image's packages: its Ruby, every gem with every version, and every OS
# package with its version. The one place this is decided, so the two images
# compared, the bare image and the deployed image, are listed alike.
readonly LIST='ruby --version && gem list && apk list --installed | sort'

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} image IMAGE
         ${MY_NAME} container CONTAINER

    Prints an image's packages: its ruby --version, every gem with every
    version (gem list), and every OS package (apk list --installed), of
    IMAGE, or of the running CONTAINER. app-web/bin/run_server_tests_bare.sh
    saves those of the bare image the server tests ran in, and the workflow
    compares them with the deployed image's, attesting whether they match.

    Options:
       -h     Show this help

    Example:
       ${MY_NAME} image cyberdojo/web:bcb5902

EOF
}

main()
{
  case "${1:-}:${2:-}" in
    -h:* | --help:*)
      show_help
      exit 0
      ;;
    image:?*)
      docker run --rm --entrypoint sh "${2}" -c "${LIST}"
      ;;
    container:?*)
      docker exec "${2}" sh -c "${LIST}"
      ;;
    *)
      show_help
      >&2 echo "ERROR: expected image IMAGE or container CONTAINER"
      exit 42
      ;;
  esac
}

main "$@"
