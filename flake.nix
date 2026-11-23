{
  description = "c211-i131063 nonce probe";
  outputs = { self }: {
    apps.x86_64-linux.ci-nix-check = {
      type = "app";
      program = "${./probe.sh}";
    };
  };
}
