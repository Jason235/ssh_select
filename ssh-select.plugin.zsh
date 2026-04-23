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
  local -A host_info host_user
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
        "HostName "*) host_info[$current_host]="${line#HostName }" ;;
        "User "*)     host_user[$current_host]="${line#User }" ;;
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

  # Build display with aligned columns
  local -a display_list
  local h max_len=0
  for h in "${hosts[@]}"; do
    (( ${#h} > max_len )) && max_len=${#h}
  done

  for h in "${hosts[@]}"; do
    local ip="${host_info[$h]}"
    local user="${host_user[$h]:-}"
    local pad="${(l:$((max_len - ${#h} + 2)):: :)}"
    if [[ -n "$user" ]]; then
      display_list+=("$h${pad}${user}@${ip}")
    else
      display_list+=("$h${pad}${ip}")
    fi
  done

  local selected
  selected=$(printf '%s\n' "${display_list[@]}" \
    | fzf \
      --prompt="SSH > " \
      --height=~50% \
      --border=rounded \
      --margin=1 \
      --padding=1 \
      --info=inline \
      --header="$(tput bold)  Host$(printf '%*s' $((max_len-1)))  Address$(tput sgr0)" \
      --color="fg:#c0c0c0,bg:#1a1a2e,hl:#ff6b6b:bold" \
      --color="fg+:#ffffff,bg+:#16213e,hl+:#ff6b6b:bold" \
      --color="prompt:#4ecdc4,header:#e2e2e2:bold,border:#4ecdc4" \
      --color="pointer:#4ecdc4,marker:#ff6b6b,spinner:#4ecdc4" \
      --pointer=">" \
      --marker=">" \
      --bind 'shift-tab:up,tab:down' \
  )

  if [[ -n "$selected" ]]; then
    local chosen_host="${selected%% *}"
    ssh "$chosen_host"
  fi
}
