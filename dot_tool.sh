#!/bin/bash
set -e

TOOL_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_ROOT="$( cd "${TOOL_ROOT}/dotfiles" && pwd )"
MAX_DEPTH="3" # speed up most commands by limiting homedir traversal
HOME_DIR="${HOME}"
DRY_RUN="false"
BACKUP_SUFFIX='.dotfilesbak'

function usage() {
  echo "usage: dot_tool.sh -a [update|find_backups|find_broken] [-d] [-t target] [-s source]"
  echo "-a for action. required."
  echo ""
  echo "optional:"
  echo "-d for dry run"
  echo "-t to override target home dir. default: ${HOME_DIR}"
  echo "-s to override source dotfiles dir. default: ${DOTFILES_ROOT}"
  exit 1
}

function find_backups() {
  find "${HOME_DIR}" -maxdepth "${MAX_DEPTH}" -name "*${BACKUP_SUFFIX}"
}

function find_broken() {
  find -L "${HOME_DIR}" -maxdepth "${MAX_DEPTH}" -type 'l' -lname "${DOTFILES_ROOT}/*"
}

function delete_broken() {
  # delete broken symlinks
  while read f; do
    echo "remove dead link: rm ${f} -> $(readlink "${f}")"
    "${DRY_RUN}" || rm "${f}"
  done< <(find_broken)
}

function update() {
  delete_broken

  # list out dot files in the repo
  pushd "${DOTFILES_ROOT}" &> /dev/null
  DOTFILES="$(find . -type 'f' | sed 's#^./##')"
  popd &> /dev/null

  # create missing directories in homedir
  while read dir ; do
    local absolute_dir="${HOME_DIR}/${dir}"

    if [ ! -d "${absolute_dir}" ]; then
      echo "creating directory: ${absolute_dir}"
      "${DRY_RUN}" || mkdir -p "${absolute_dir}"
    fi
  done< <(echo "${DOTFILES}" | xargs -n 1 dirname | sort | uniq)

  # create any missing or wrong symlinks in homedir
  while read dotf ; do
    local home_link="${HOME_DIR}/${dotf}"
    local link_target="${DOTFILES_ROOT}/${dotf}"

    if [ "$(readlink "${home_link}")" == "${link_target}" ]; then
      # already correct
      continue
    else
      # backup if needed
      if [ -f "${home_link}" -o -L "${home_link}" ]; then
        local backup_path="${home_link}${BACKUP_SUFFIX}"

        echo "backup: mv '${home_link}' '${backup_path}'"
        "${DRY_RUN}" || mv "${home_link}" "${backup_path}"
      fi

      # create new link
      echo "new link: ln -s '${link_target}' '${home_link}'"
      "${DRY_RUN}" || ln -s "${link_target}" "${home_link}"
    fi
  done< <(echo "${DOTFILES}")
}

while getopts 'a:,t:,s:,d' opt; do
  case "${opt}" in
    d)
      DRY_RUN="true"
      ;;
    a)
      ACTION="$OPTARG"
      ;;
    t)
      HOME_DIR="$OPTARG"
      ;;
    s)
      DOTFILES_ROOT="$OPTARG"
      ;;
  esac
done

case "${ACTION}" in
  update)
    update ;;
  find_backups)
    find_backups ;;
  find_broken)
    find_broken ;;
  *)
    usage ;;
esac
