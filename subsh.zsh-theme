#!/usr/bin/env zsh

# used prompt expansions:
#
# %F{color}  set fg color
# %f         reset fg color
#
# %K{color}  set bg color
# %k         reset bg color
#
# %D{%H:%M}  24h clock with leading zero (01:23)
#
# %n         username
# %m         hostname up to first dot (hostname from $HOST)
# %~         cwd, ~ instead of home path

prompt_git() {
  if ! git rev-parse 2>/dev/null; then
    return
  fi

  readonly git_branch="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
  if [[ -n "$git_branch" ]]; then
    echo -n "%F{blue}:$git_branch%f"
    return
  fi

  readonly git_tag="$(git tag --points-at HEAD 2>/dev/null | head -1)"
  if [[ -n "$git_tag" ]]; then
    echo -n "%F{red}:$git_tag%f"
    return
  fi

  readonly git_commit="$(git rev-parse --short HEAD)"
  echo -n "%F{yellow}:$git_commit%f"
}

# 1✘23:14user@host~/.sub.sh:master❯
build_prompt() {
  readonly code="$?"
  readonly theme="${SUBSH_ZSH_THEME:-green}"

  # $?✘ (only when the last execution was failed)
  echo -n "%(?::%F{red}$code✘%f)"

  # 23:14
  echo -n "%D{%H:%M}"

  # root: hostname
  # other: username@hostname
  if [[ "$UID" -eq 0 ]]; then
    echo -n "%F{$theme}%m%f"
  else
    echo -n "%F{$theme}%n@%m%f"
  fi

  # ~/.sub.sh
  echo -n "%~"

  # :develop (only in git repo)
  prompt_git

  # ❯
  echo -n "%F{$theme}❯%f"
}
PROMPT='$(build_prompt) '

# show elapsed time at the RPROMPT if slower than 3sec.
start-timer() {
  SUBSH_ZSH_TIMER="$SECONDS"
}
stop-timer-rprompt() {
  RPROMPT=''
  if [[ -z "$SUBSH_ZSH_TIMER" ]]; then
    return
  fi

  local elapsed
  elapsed="$(($SECONDS - $SUBSH_ZSH_TIMER))"
  unset SUBSH_ZSH_TIMER

  if [[ "$elapsed" -lt 3 ]]; then
    # ~3sec: show nothing
    RPROMPT=''
  elif [[ "$elapsed" -lt 600 ]]; then
    # 3sec~10min: ↳42sec (yellow)
    RPROMPT="%F{yellow}↳%S${elapsed}sec%s%f"
  else
    # 10min~: ↳23min (red)
    RPROMPT="%F{red}↳%S$((elapsed/60))min%s%f"
  fi
}
preexec_functions+=(start-timer)
precmd_functions+=(stop-timer-rprompt)
