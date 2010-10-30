# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils confutils

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://git.samba.org/${PN}.git"
	inherit git autotools
else
	SRC_URI="ftp://ftp.samba.org/pub/linux-cifs/${PN}/${P}.tar.bz2"
fi

DESCRIPTION="Tools for Managing Linux CIFS Client Filesystems"
HOMEPAGE="http://www.samba.org/linux-cifs/cifs-utils/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ads +caps caps-ng setuid"

DEPEND="!net-fs/mount-cifs
	!net-fs/samba-client
	!<net-fs/samba-3.6
	ads? ( sys-libs/talloc virtual/krb5 sys-apps/keyutils )
	caps? ( sys-libs/libcap )
	caps-ng? ( sys-libs/libcap-ng )"
RDEPEND="${DEPEND}"

pkg_setup() {
	confutils_use_conflict caps caps-ng
}

src_prepare() {
	if [[ ${PV} == 9999 ]]; then
		eautoreconf || die "eautoreconf failed"
	fi
}

src_configure() {
	econf \
		$(use_enable ads cifsupcall) \
		$(use_with caps libcap) \
		$(use_with caps-ng libcap-ng)
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"

	if use setuid ; then
		chmod u+s "${D}/sbin/mount.cifs"
	fi
}

pkg_postinst() {
	# Set set-user-ID bit of mount.cifs 
	if use setuid ; then
		ewarn "Setting SETUID bit for mount.cifs."
		ewarn "However, there may be severe securuty implications. Also see:"
		ewarn "http://samba.org/samba/security/CVE-2009-2948.html"
	fi

	# Inform about upcall usage
	if use ads ; then
		ewarn "Using mount.cifs in combination with keyutils"
		ewarn "in order to mount DFS shares, you need to add"
		ewarn "the following line to /etc/request-key.conf:"
		ewarn "  create dns_resolver * * /usr/sbin/cifs.upcall %k"
		ewarn "Otherwise, your DFS shares will not work properly."
	fi
}
