export LANG='en_US.UTF-8'
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/zash.omp.json')"
  eval "$(zoxide init zsh --cmd cd)"
fi
