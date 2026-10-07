{
  pkgs,
  vault,
  usbMount,
  home,
  wrapperDir,
}:
let
  idle = "10m";
in
pkgs.writeShellApplication {
  name = "vault";
  runtimeInputs = with pkgs; [
    git
    gocryptfs
    util-linux
    uutils-coreutils-noprefix
  ];
  text = ''
    usb_device=/dev/disk/by-uuid/${vault.usb}
    usb_mount=${usbMount}
    usb_repo="$usb_mount/vault"
    usb_key="$usb_mount/vault-key"
    passphrase="$usb_key/passphrase"

    nvme_cipher=${home}/.local/share/vault
    nvme_mount=${home}/vault
    hdd_cipher=${vault.hdd}
    hdd_mount="$XDG_RUNTIME_DIR/vault-hdd"

    usb_attached_by_vault=false

    usb_attach() {
    	if mountpoint -q "$usb_mount"; then
    		return
    	fi

    	if [[ ! -e $usb_device ]]; then
    		echo "usb stick not plugged" >&2
    		exit 1
    	fi

    	${wrapperDir}/mount "$usb_mount"
    	usb_attached_by_vault=true
    }

    unlock() {
    	local cipher=$1 mount=$2
    	shift 2

    	if mountpoint -q "$mount"; then
    		return
    	fi

    	mkdir -p "$mount"

    	if [[ -e $usb_device ]]; then
    		usb_attach
    		gocryptfs -q -passfile "$passphrase" "$@" "$cipher" "$mount"
    	else
    		gocryptfs -q "$@" "$cipher" "$mount"
    	fi
    }

    lock() {
    	if mountpoint -q "$1"; then
    		${wrapperDir}/fusermount3 -u "$1"
    	fi
    }

    cleanup() {
    	lock "$hdd_mount"

    	if [[ $usb_attached_by_vault == true ]]; then
    		${wrapperDir}/umount "$usb_mount"
    	fi
    }

    usb_has_commit() {
    	git -C "$usb_repo" rev-parse -q --verify refs/heads/main >/dev/null
    }

    nvme_has_commit() {
    	git -C "$nvme_mount" rev-parse -q --verify HEAD >/dev/null 2>&1
    }

    synchronize() {
    	usb_attach
    	unlock "$nvme_cipher" "$nvme_mount" -idle ${idle}
    	unlock "$hdd_cipher" "$hdd_mount"

    	git -C "$usb_repo" config receive.denyCurrentBranch updateInstead

    	local before
    	before=$(git -C "$nvme_mount" rev-parse HEAD)
    	if usb_has_commit; then
    		git -C "$nvme_mount" pull -q --no-rebase --no-edit "$usb_repo" main
    	fi
    	git -C "$nvme_mount" diff --stat "$before" HEAD

    	git -C "$nvme_mount" push -q "$hdd_mount" main
    	git -C "$nvme_mount" push -q "$usb_repo" main

    	for repo in "$nvme_mount" "$hdd_mount" "$usb_repo"; do
    		git -C "$repo" fsck --no-progress --no-dangling
    	done

    	cp "$nvme_cipher/gocryptfs.conf" "$usb_key/gocryptfs-nvme.conf"
    	cp "$hdd_cipher/gocryptfs.conf" "$usb_key/gocryptfs-hdd.conf"
    	sync

    	echo "synced"
    }

    initialize() {
    	usb_attach
    	mkdir -p "$usb_key"

    	if [[ ! -e $passphrase ]]; then
    		local first second
    		read -rsp "new passphrase: " first
    		echo
    		read -rsp "repeat: " second
    		echo

    		if [[ $first != "$second" ]]; then
    			echo "mismatch" >&2
    			exit 1
    		fi

    		printf '%s' "$first" >"$passphrase"
    	fi

    	for cipher in "$nvme_cipher" "$hdd_cipher"; do
    		if [[ ! -e $cipher/gocryptfs.conf ]]; then
    			mkdir -p "$cipher"
    			gocryptfs -init -q -passfile "$passphrase" "$cipher"
    		fi
    	done

    	unlock "$nvme_cipher" "$nvme_mount" -idle ${idle}

    	if nvme_has_commit; then
    		echo "vault already initialized" >&2
    		exit 1
    	fi

    	unlock "$hdd_cipher" "$hdd_mount"

    	for repo in "$usb_repo" "$nvme_mount"; do
    		if [[ ! -e $repo/.git ]]; then
    			git init -q -b main "$repo"
    		fi

    		git -C "$repo" config user.name "$(git config --global user.personal.name)"
    		git -C "$repo" config user.email "$(git config --global user.personal.email)"
    	done

    	if [[ ! -e $hdd_mount/HEAD ]]; then
    		git init -q --bare -b main "$hdd_mount"
    	fi

    	if usb_has_commit; then
    		git -C "$nvme_mount" pull -q "$usb_repo" main
    	else
    		git -C "$nvme_mount" commit -q --allow-empty -m init
    	fi

    	synchronize
    }

    trap cleanup EXIT

    case "''${1:-}" in
    open)
    	unlock "$nvme_cipher" "$nvme_mount" -idle ${idle}
    	echo "$nvme_mount"
    	;;
    close)
    	lock "$nvme_mount"
    	;;
    sync)
    	synchronize
    	;;
    init)
    	initialize
    	;;
    *)
    	echo "usage: vault open|close|sync|init" >&2
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    	;;
    esac
  '';
}
