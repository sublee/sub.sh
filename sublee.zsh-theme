#!/usr/bin/env zsh

prompt_status() {
  # 23:14
  echo -n "%{$fg[blue]%}%T%{$reset_color%}"
  # ✘ (only when the last execution was failed)
  echo -n "%(?::%{$fg[red]%}✘%{$reset_color%})"
}

prompt_user() {
  # user@hostname❯
  if [[ $UID -ne 0 ]]
  then
    echo -n "%{$fg[green]%}%n@%m%{$fg[cyan]%}❯%{$reset_color%}"
  fi
}

prompt_dir() {
  # ~/.oh-my-zsh/custom
  echo -n "%~"
}

prompt_git() {
  # :develop
  git rev-parse 2>/dev/null || return
  GIT_BRANCH=`git symbolic-ref -q --short HEAD 2>/dev/null`
  GIT_COMMIT=`git show-ref --head -s --abbrev | head -n1`
  if [[ -z $GIT_BRANCH ]]
  then
    echo -n "%{$fg[yellow]%}:$GIT_COMMIT"
  elif [[ $GIT_BRANCH != "master" ]]
  then
    echo -n "%{$fg[magenta]%}:$GIT_BRANCH"
  fi
}

prompt_end() {
  # ¶ or ❯
  if [[ $UID -eq 0 ]]
  then
    echo -n "%{$fg[blue]%}¶"
  else
    echo -n "%{$fg[cyan]%}❯"
  fi
  echo -n "%{$reset_color%}"
}

# 23:14✘user@hostname❯~/.oh-my-zsh/custom:develop❯
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
    RPROMPT="%F{yellow}${elapsed}sec%{$reset_color%}"
  else
    # 10min~: (red) 23min
    RPROMPT="%F{red}$((elapsed/60))min%{$reset_color%}"
  fi
}
