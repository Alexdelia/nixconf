rec {
  trail = "rg '\\s$'";
  trail-rm = "sd '[^\\S\\n]*$' ''";

  df = "dysk -c label+mount+use+size+used+free -s use";

  ani = "ani-cli -c";
  anib = "ani-cli --dub -c";

  dc = "docker compose";
  dcd = "docker compose -f docker-compose.dev.yml";
  dcl = "${dc} logs --no-log-prefix --follow";
  dcdl = "${dcd} logs --no-log-prefix --follow";
}
