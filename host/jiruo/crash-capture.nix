{
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 1;
    "kernel.softlockup_panic" = 1;
    "kernel.hardlockup_panic" = 1;
    "kernel.hung_task_panic" = 1;
    "kernel.hung_task_timeout_secs" = 300;
    "kernel.panic_on_io_nmi" = 1;
    "kernel.panic_on_unrecovered_nmi" = 1;
    "kernel.panic" = 60;
  };
}
