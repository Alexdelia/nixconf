if ! getent group keyheat >/dev/null; then
  sudo groupadd --system keyheat
fi

if ! id keyheat >/dev/null 2>&1; then
  sudo useradd --system --gid keyheat --no-create-home --home-dir /nonexistent --shell /usr/sbin/nologin keyheat
fi

sudo usermod -aG keyheat "$KEYHEAT_USER"

sudo ln -sfn "$KEYHEAT_UNIT" /nix/var/nix/gcroots/keyheat-unit
sudo install -m 0644 "$KEYHEAT_UDEV_RULE" /etc/udev/rules.d/99-keyheat.rules
sudo udevadm control --reload
sudo install -m 0644 "$KEYHEAT_UNIT" /etc/systemd/system/keyheat.service
sudo systemctl daemon-reload
sudo systemctl enable keyheat
sudo systemctl restart keyheat
systemctl --user restart swhkd

echo "keyheat installed; log out and in for group keyheat"
