let
  SIGNAL_PREFIX = "[SIG](dimmed red)";
in {
  disabled = false;

  format = "[$status $symbol$signal_name[$common_meaning](dimmed red)]($style)\n";

  style = "bold red";

  map_symbol = true;

  symbol = "";
  success_symbol = "";
  not_executable_symbol = "[chmod +x](bold cyan) ";
  not_found_symbol = "[](bold yellow)  ";
  sigint_symbol = "[](red)  ${SIGNAL_PREFIX}";
  signal_symbol = SIGNAL_PREFIX;

  pipestatus = true;
}
