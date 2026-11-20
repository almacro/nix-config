{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # JVM — one JDK flavour: headless (openjdk-headless on Linux; on macOS the
    # headless alias is the standard Zulu JDK). Switch to the GUI jdk21 only if
    # something actually needs AWT/Swing.
    jdk21_headless
    maven
    gradle
    mill

    # Lisp / Clojure
    sbcl
    guile
    leiningen
    clojure
    clojure-lsp
    babashka
    racket

    # Deno (grouped here per the original common layout)
    deno
  ];

  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21_headless}";
}
