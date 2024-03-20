let
 pkgs = import (fetchTarball "https://github.com/jbedo/nixpkgs/archive/3607b504a20ffc638179936642923c48afbdf706.tar.gz") {};
 system_packages = builtins.attrValues {
  inherit (pkgs) R glibcLocalesUtf8;
};
 r_packages = builtins.attrValues {
  inherit (pkgs.rPackages) devtools clipr diffobj dplyr ggplot2 maybe rlang stringr tibble knitr lubridate purrr rmarkdown testthat tidyr rhub fusen;
};
  tex = (pkgs.texlive.combine {
  inherit (pkgs.texlive) scheme-small;
});
  in
  pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";

    buildInputs = [ system_packages r_packages tex];

  }