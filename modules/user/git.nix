{ ... }: {
  programs.git = {
    enable = true;
    signing = {
      key = "059F098EBF0E9A13E10A46BF6500251E087653C9";
      signByDefault = true;
    };
    settings = {
      user.name = "Cilly Leang";
      user.email = "mini@cilly.moe";
      core.abbrev = 11;
      safe.directory = "/home/rin/Projects/flakes";
    };
  };
}
