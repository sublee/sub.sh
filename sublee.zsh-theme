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
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    if [[ -n $(parse_git_dirty) ]]; then
      echo -n "%{$fg[yellow]%}★"
    fi
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
