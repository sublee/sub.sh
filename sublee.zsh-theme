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
# %m         hostname up to first dot
# %~         cwd, ~ instead of home path

prompt_status() {
  # ✘$? (only when the last execution was failed)
  echo -n "%(?::%F{red}✘"$?"%f)"
  # 23:14
  echo -n "%F{blue}%D{%H:%M}%f"
}

prompt_user() {
  # fantine
  echo -n "$(subsh-hostname|subsh-hostcolor)"
  if [[ "$UID" -eq 0 ]]; then
    echo -n "%F{yellow}✼%f"
  fi
}

prompt_dir() {
  # ~/.oh-my-zsh/custom
  echo -n "%~"
}

prompt_git() {
  # :develop (only in git repo)
  if ! git rev-parse 2>/dev/null
  then
    return
  fi

  local git_branch
  git_branch="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
  if [[ -n "$git_branch" ]]
  then
    echo -n "%F{magenta}:$git_branch%f"
    return
  fi

  local git_tag
  git_tag="$(git tag --points-at HEAD 2>/dev/null | head -1)"
  if [[ -n "$git_tag" ]]
  then
    echo -n "%F{red}:$git_tag%f"
    return
  fi

  local git_commit
  git_commit="$(git rev-parse --short HEAD)"
  echo -n "%F{yellow}:$git_commit%f"
}

prompt_sep() {
  # ❯
  if [[ "$UID" -eq 0 ]]; then
    echo -n "%F{yellow}❯%f"
  else
    echo -n "%F{cyan}❯%f"
  fi
}

# 23:14✘sub@fantine❯~/.oh-my-zsh/custom:develop❯
build_prompt() {
  prompt_status
  prompt_user
  prompt_sep
  prompt_dir
  prompt_git
  prompt_sep
}
PROMPT='$(build_prompt) '

# show elapsed time at the RPROMPT if slower than 3sec.
start-timer() {
  ZSH_SUBLEE_TIMER="$SECONDS"
}
stop-timer-rprompt() {
  RPROMPT=''
  if [[ -z "$ZSH_SUBLEE_TIMER" ]]
  then
    return
  fi

  local elapsed
  elapsed="$(($SECONDS - $ZSH_SUBLEE_TIMER))"
  unset ZSH_SUBLEE_TIMER

  if [[ "$elapsed" -lt 3 ]]
  then
    # ~3sec: show nothing
    RPROMPT=''
  elif [[ "$elapsed" -lt 600 ]]
  then
    # 3sec~10min: ↳42sec (yellow)
    RPROMPT="%F{yellow}↳%S${elapsed}sec%s%f"
  else
    # 10min~: ↳23min (red)
    RPROMPT="%F{red}↳%S$((elapsed/60))min%s%f"
  fi
}
preexec_functions+=(start-timer)
precmd_functions+=(stop-timer-rprompt)
