export LANG='en_US.UTF-8'
export EDITOR=vim
export VISUAL="$EDITOR"
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config '/Users/trueberryless/oh-my-posh.omp.json')"
  eval "$(zoxide init zsh --cmd cd)"
fi
