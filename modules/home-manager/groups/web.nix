{ pkgs, ... }:
{
  # JavaScript / TypeScript (deno lives in lisp-jvm per the original layout)
  home.packages = with pkgs; [
    nodejs
    bun
    pnpm
    typescript
    prettier
    eslint
  ];
}
