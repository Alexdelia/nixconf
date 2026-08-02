{ pkgs, ... }: {
  security.wrappers.swhkd = {
    source = "${pkgs.swhkd-no-rfkill}/bin/swhkd";
    owner = "root";
    group = "root";
    setuid = true;
  };
}
