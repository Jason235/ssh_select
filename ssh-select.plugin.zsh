#!/usr/bin/env zsh
#
# ssh-select - Interactive SSH host picker (using fzf)
# Usage: ssh-select [host]

ssh-select() {
  local SSH_CONFIG="$HOME/.ssh/config"

  if [[ ! -f "$SSH_CONFIG" ]]; then
    echo "Error: ~/.ssh/config not found" >&2
    return 1
  fi

  # Parse ssh config
  local -A host_info host_user host_port host_id
  local current_host=""

  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue

    if [[ "$line" = "Host "* ]]; then
      current_host="${line#Host }"
    elif [[ -n "$current_host" ]]; then
      case "$line" in
        "HostName "*)    host_info[$current_host]="${line#HostName }" ;;
        "User "*)        host_user[$current_host]="${line#User }" ;;
        "Port "*)        host_port[$current_host]="${line#Port }" ;;
        "IdentityFile "*) host_id[$current_host]="${line#IdentityFile }" ;;
      esac
    fi
  done < "$SSH_CONFIG"

  local -a hosts
  hosts=("${(@k)host_info}")

  # Direct connect
  if [[ $# -eq 1 ]]; then
    local target="$1"
    if [[ ${hosts[(i)$target]} -le ${#hosts} ]]; then
      ssh "$target"
      return $?
    else
      echo "Error: Host '$target' not found" >&2
      return 1
    fi
  fi

  if [[ -z "$hosts" ]]; then
    echo "Error: No hosts found in ~/.ssh/config" >&2
    return 1
  fi

  # Colors
  local D=$'\033[2m' BD=$'\033[1m' RS=$'\033[0m'
  local C=$'\033[36m' G=$'\033[32m' M=$'\033[35m'

  # Build display with colored columns
  local -a display_list
  local h max_len=0
  for h in "${hosts[@]}"; do
    (( ${#h} > max_len )) && max_len=${#h}
  done

  for h in "${hosts[@]}"; do
    local ip="${host_info[$h]}"
    local user="${host_user[$h]:-}"
    local pad="${(l:$((max_len - ${#h} + 2)):: :)}"
    local addr="${user:+${C}${user}${RS}${D}@${RS}}${G}${ip}${RS}"
    display_list+=("${BD}${h}${RS}${pad}${addr}")
  done

  # Header
  local header="${M} Host$(printf '%*s' $((max_len-1)))Address${RS}"

  local selected
  selected=$(printf '%s\n' "${display_list[@]}" \
    | fzf \
      --ansi \
      --prompt="SSH > " \
      --height=~60% \
      --border=rounded \
      --margin=1,2 \
      --padding=1,2 \
      --info=inline \
      --header="$header" \
      --color="fg:#a6adc8,bg:#1e1e2e,hl:#f5c2e7" \
      --color="fg+:#cdd6f4,bg+:#313244,hl+:#f5c2e7:bold" \
      --color="prompt:#cba6f7,header:#cba6f7,border:#45475a" \
      --color="pointer:#cba6f7:bold,marker:#f5c2e7,spinner:#cba6f7" \
      --color="gutter:#1e1e2e" \
      --pointer="❯" \
      --marker="❯" \
      --preview="${0:A:h}/_ssh_select_preview '{}'" \
      --preview-window=right:50%:border-left \
      --bind 'shift-tab:up,tab:down' \
      --bind 'esc:abort,q:abort' \
  )

  if [[ -n "$selected" ]]; then
    local clean="${selected//$'\033'\[*m/}"
    local chosen_host="${clean%% *}"
    ssh "$chosen_host"
  else
    echo "  Aborted ssh-select"
  fi
}
