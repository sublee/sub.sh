#!/usr/bin/env zsh

prompt_status() {
  echo -n "%(?::%{$fg[red]%}✘%{$reset_color%})"
}
prompt_user() {
  if [[ $UID -ne 0 ]] then
    echo -n "%{$fg[green]%}%n@%m%{$fg[cyan]%}❯"
  fi
}
prompt_dir() {
  echo -n "%{$reset_color%}%~"
}
prompt_git() {
  git rev-parse 2>/dev/null || return
  GIT_BRANCH=`git symbolic-ref -q --short HEAD 2>/dev/null`
  GIT_COMMIT=`git show-ref --head -s --abbrev | head -n1`
  if [[ -z $GIT_BRANCH ]]; then
    echo -n "%{$fg[yellow]%}:$GIT_COMMIT"
  elif [[ $GIT_BRANCH != "master" ]]; then
    echo -n "%{$fg[blue]%}:$GIT_BRANCH"
  fi
}
prompt_end() {
  if [[ $UID -eq 0 ]] then
    echo -n "%{$fg[blue]%}¶"
  else
    echo -n "%{$fg[cyan]%}❯"
  fi
  echo -n "%{$reset_color%}"
}
build_prompt() {
  prompt_status
  prompt_user
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='$(build_prompt) '
RPROMPT=''
