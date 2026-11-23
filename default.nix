let
 pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2026-11-16.tar.gz") {};

  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      codemetar
      codetools
      devtools
      diffobj
      diffviewer
      ggplot2
      jsonlite
      knitr
      languageserver
      lubridate
      maybe
      openxlsx
      purrr
      rhub
      rlang
      rmarkdown
      stringr
      styler
      sys
      testthat
      tibble
      tidyr
      urlchecker
      ;
  };

  tex = pkgs.texliveSmall.withPackages (ps: with ps; [
    inconsolata
  ]);
  
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      air-formatter
      glibcLocales
      glibcLocalesUtf8
      nix
      pandoc
      R;
  };

in

pkgs.mkShell {
  LOCALE_ARCHIVE = if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LANG = "en_US.UTF-8";
   LC_ALL = "en_US.UTF-8";
   LC_TIME = "en_US.UTF-8";
   LC_MONETARY = "en_US.UTF-8";
   LC_PAPER = "en_US.UTF-8";
   LC_MEASUREMENT = "en_US.UTF-8";

  buildInputs = rpkgs ++ [ tex ] ++ system_packages;

}
