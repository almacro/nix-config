for p in font-awesome nerd-fonts.symbols-only noto-fonts-color-emoji; do
  printf '%s -> ' "$p"; nix eval --raw "nixpkgs#$p.name" 2>&1 | tail -1; echo
done
