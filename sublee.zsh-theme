#!/usr/bin/env zsh

# used prompt expansions:
#
# %F{color}  set fg color
# %f         reset fg color
#
# %K{color}  set bg color
# %k         reset bg color
#
# %T         24h clock (23:45)
#
# %n         username
# %m         hostname up to first dot
# %~         cwd, ~ instead of home path

prompt_status() {
  # 23:14
  echo -n "%F{blue}%T%f"
  # ✘ (only when the last execution was failed)
  echo -n "%(?::%F{red}✘%f)"
}

prompt_user() {
  # sub@fantine❯
  if [[ $UID -ne 0 ]]
  then
    echo -n "%F{green}%n@%m%F{cyan}❯%f"
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
  local git_commit
  git_branch="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
  git_commit="$(git show-ref --head -s --abbrev | head -n1)"

  if [[ -z "$git_branch" ]]
  then
    echo -n "%F{yellow}:$git_commit%f"
  else
    echo -n "%F{magenta}:$git_branch%f"
  fi
}

prompt_end() {
  # ¶ (for root)
  # ❯ (for others)
  if [[ "$UID" -eq 0 ]]
  then
    echo -n "%F{red}¶%f"
  else
    echo -n "%F{cyan}❯%f"
  fi
}

# 23:14✘sub@fantine❯~/.oh-my-zsh/custom:develop❯
build_prompt() {
  prompt_status
  prompt_user
  prompt_dir
  prompt_git
  prompt_end
}
PROMPT='$(build_prompt) '

# show elapsed time at the RPROMPT if slower than 3sec.
preexec() {
  ZSH_SUBLEE_TIMER="$SECONDS"
}
precmd() {
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
    # 3sec~10min: (yellow) 42sec
    RPROMPT="%F{yellow}${elapsed}sec%f"
  else
    # 10min~: (red) 23min
    RPROMPT="%F{red}$((elapsed/60))min%f"
  fi
}
