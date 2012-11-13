if [[ ! -o interactive ]]; then
    return
fi

compctl -K _aj aj

_aj() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(aj commands)"
  else
    completions="$(aj completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
