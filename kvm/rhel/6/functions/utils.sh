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
      key=${arg%%=*}; key=${key##--}; key=${key//-/_}
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

function extract_dirname() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  cd $(dirname ${filepath}) && pwd
}

function expand_path() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  echo $(extract_dirname ${filepath})/$(basename ${filepath})
}

function extract_path() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  local tmp_path=${filepath}
  local tmp_dirname=$(extract_dirname ${filepath})

  [[ -L "${filepath}" ]] && {
    tmp_path=$(readlink ${filepath})
    tmp_path=$(extract_dirname ${tmp_dirname}/${tmp_path})/$(basename ${tmp_path})
  } || {
    tmp_path=${tmp_dirname}/$(basename ${tmp_path})
  }

  # nested symlink?
  [[ -L "${tmp_path}" ]] && {
    extract_path ${tmp_path}
  } || {
    echo ${tmp_path}
  }
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
  [[ "${UID}" -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

function is_dev() {
  local disk_filename=$1
  # do not use "-a" in this case.
  [[ -n "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (utils:${LINENO})" >&2; return 1; }

  case "${disk_filename}" in
  /dev/*) return 0 ;;
       *) return 1 ;;
  esac
}

function is_dmdev() {
  local disk_filename=$1
  # do not use "-a" in this case.
  [[ -n "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (utils:${LINENO})" >&2; return 1; }

  disk_filename=$(extract_path ${disk_filename})

  case "${disk_filename}" in
  /dev/dm-[0-9]*) return 0 ;;
               *) return 1 ;;
  esac
}

function get_suffix() {
  [[ -n "${1}" ]] || { echo "[ERROR] Invalid argument: empty (disk:${LINENO})" >&2; return 1; }

  echo ${1##*.}
}
