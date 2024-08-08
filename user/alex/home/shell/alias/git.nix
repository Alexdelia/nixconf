{
  gg = "git clone --recurse-submodules";

  gst = "git status --short";
  gs = "git status --short";

  gd = "git diff";
  gdl = "git diff HEAD~1";
  gds = "git diff --staged";

  gi = "git log --graph --stat --all --pretty='%n%C(magenta)╭╴%C(auto)%h%C(magenta)╶╴%C(bold green)%an%Creset%C(magenta)╶╴%C(green)%ae%C(magenta)╶╴%C(bold blue)%ch%Creset%n%C(magenta)╰╴%C(auto)%s%Creset'";
  glast = "git --no-pager log -n1 --pretty='%C(magenta)╭╴%C(auto)%h%C(magenta)╶╴%C(bold green)%an%Creset%C(magenta)╶╴%C(green)%ae%C(magenta)╶╴%C(bold blue)%ch%Creset%n%C(magenta)╰╴%C(auto)%s%Creset'";
  gtree = "git log --graph --oneline --decorate --all";

  gc = "git commit --message";
  gops = "git reset HEAD~1 --soft";

  gl = "git pull";
  gp = "git push";
  gf = "git fetch";

  go = "git checkout";
  gb = "git branch";

  gm = "git merge";

  gk = "git cherry-pick";

  gid = "git identify";
}
