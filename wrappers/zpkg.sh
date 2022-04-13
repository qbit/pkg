zpkg() {
	/usr/local/sbin/pkg search "$@" | \
		fzf --preview "/usr/local/sbin/pkg pkginfo {1}"
}
