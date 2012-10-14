# -*-Shell-script-*-
#
# description:
#  Various utility functions
#
# requires:
#  bash
#
# imports:
#

function extract_args() {
  CMD_ARGS=
  local arg=
  for arg in ${*}; do
    case "${arg}" in
    --*=*)
      key=${arg%%=*}; key=$(echo ${key##--} | tr - _)
      value=${arg##--*=}
      eval "${key}=\"${value}\""
      ;;
    *)
      CMD_ARGS="${CMD_ARGS} ${arg}"
      ;;
    esac
  done
  unset arg key value
  # trim
  CMD_ARGS=${CMD_ARGS%% }
  CMD_ARGS=${CMD_ARGS## }
}

function run_cmd() {
  #
  # Runs a command.
  #
  # Locale is reset to C to make parsing error messages possible.
  #
  export LANG=C
  export LC_ALL=C
  eval $*
}

function checkroot() {
  #
  # Check if we're running as root, and bail out if we're not.
  #
  [[ $UID -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

function is_dev() {
  local disk_filename=$1 mountpoint=$2
  # do not use "-a" in this case.
  [[ -n "${disk_filename}" ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  case "${disk_filename}" in
  /dev/*) return 0 ;;
       *) return 1 ;;
  esac
}
