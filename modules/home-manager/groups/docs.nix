{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Document conversion / typesetting
    pandoc
    tectonic # lightweight LaTeX/PDF engine for pandoc

    # Diagrams
    mermaid-cli # provides mmdc
    graphviz
    plantuml

    # PDF tooling
    poppler-utils
    qpdf

    # Plotting
    gnuplot
  ];

  # Point the npm-installed mermaid-filter at the nix-managed mmdc.
  home.sessionVariables.MERMAID_FILTER_CMD_MMDC = "${pkgs.mermaid-cli}/bin/mmdc";
}
