{
  pkgs,
  vault,
  usbMount,
  home,
  link,
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
    nvme_mount="$XDG_RUNTIME_DIR/vault"
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

    unlock_nvme() {
    	unlock "$nvme_cipher" "$nvme_mount" -idle ${idle}
    }

    unlock_hdd() {
    	unlock "$hdd_cipher" "$hdd_mount"
    }

    lock() {
    	if mountpoint -q "$1"; then
    		${wrapperDir}/fusermount3 -u "$1"
    	fi
    }

    cleanup() {
    	local status=$?

    	lock "$hdd_mount" || status=1

    	if [[ $usb_attached_by_vault == true ]]; then
    		${wrapperDir}/umount "$usb_mount" || status=1
    	fi

    	exit "$status"
    }

    has_commit() {
    	git -C "$1" rev-parse -q --verify refs/heads/main >/dev/null 2>&1
    }

    synchronize() {
    	usb_attach
    	unlock_nvme
    	unlock_hdd

    	git -C "$usb_repo" config receive.denyCurrentBranch updateInstead

    	local before
    	before=$(git -C "$nvme_mount" rev-parse HEAD)
    	for remote in "$usb_repo" "$hdd_mount"; do
    		if has_commit "$remote"; then
    			git -C "$nvme_mount" pull -q --no-rebase --no-edit "$remote" main
    		fi
    	done
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

    ask_passphrase() {
    	local first second
    	IFS= read -rsp "passphrase: " first
    	echo
    	IFS= read -rsp "repeat: " second
    	echo

    	if [[ -z $first ]]; then
    		echo "empty" >&2
    		exit 1
    	fi

    	if [[ $first != "$second" ]]; then
    		echo "mismatch" >&2
    		exit 1
    	fi

    	printf '%s' "$first" >"$passphrase"
    }

    unlock_existing() {
    	if [[ -e $nvme_cipher/gocryptfs.conf ]]; then
    		unlock_nvme || return
    	fi

    	if [[ -e $hdd_cipher/gocryptfs.conf ]]; then
    		unlock_hdd || return
    	fi
    }

    initialize() {
    	usb_attach
    	mkdir -p "$usb_key"

    	local created=false

    	if [[ ! -e $passphrase ]]; then
    		ask_passphrase
    		created=true

    		if ! unlock_existing; then
    			rm "$passphrase"
    			exit 1
    		fi
    	fi

    	for cipher in "$nvme_cipher" "$hdd_cipher"; do
    		if [[ ! -e $cipher/gocryptfs.conf ]]; then
    			mkdir -p "$cipher"
    			gocryptfs -init -q -passfile "$passphrase" "$cipher"
    			created=true
    		fi
    	done

    	unlock_nvme
    	unlock_hdd

    	local name email
    	name=$(git config --global user.personal.name)
    	email=$(git config --global user.personal.email)

    	for repo in "$usb_repo" "$nvme_mount"; do
    		if [[ ! -e $repo/.git ]]; then
    			git init -q -b main "$repo"
    			created=true
    		fi

    		git -C "$repo" config user.name "$name"
    		git -C "$repo" config user.email "$email"
    	done

    	if [[ ! -e $hdd_mount/HEAD ]]; then
    		git init -q --bare -b main "$hdd_mount"
    		created=true
    	fi

    	if ! has_commit "$nvme_mount"; then
    		created=true

    		if has_commit "$usb_repo"; then
    			git -C "$nvme_mount" pull -q "$usb_repo" main
    		elif has_commit "$hdd_mount"; then
    			git -C "$nvme_mount" pull -q "$hdd_mount" main
    		else
    			git -C "$nvme_mount" commit -q --allow-empty -m init
    		fi
    	fi

    	if [[ $created == false ]]; then
    		echo "vault already initialized" >&2
    		exit 1
    	fi

    	synchronize
    }

    trap cleanup EXIT

    case "''${1:-}" in
    open)
    	unlock_nvme
    	echo "${link}"
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
