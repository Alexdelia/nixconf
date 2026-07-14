{
  pkgs,
  config,
  ...
}: {
  dp.calculator = config.terminal.exec {
    command = "${pkgs.numbat}/bin/numbat";
    fontSize = 48;
  };

  imports = [
    ./numbat
  ];
}
