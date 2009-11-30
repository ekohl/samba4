# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba-libs/samba-libs-3.4.3-r1.ebuild,v 1.2 2009/11/08 03:27:34 josejx Exp $

EAPI="2"

inherit pam confutils versionator multilib autotools

MY_PV="${PV/_alpha/alpha}"
MY_P="samba-${MY_PV}"

DESCRIPTION="Library bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug dso gnutls +netapi sqlite threads"

DEPEND="dev-libs/popt
	sys-libs/readline
	>=sys-libs/tdb-1.1.5
	virtual/libiconv
	caps? ( sys-libs/libcap )
	debug? ( dev-libs/dmalloc )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )"
	# >=sys-libs/talloc-1.3.0

RDEPEND="${DEPEND}"

RESTRICT="test nomirror"

S="${WORKDIR}/${MY_P}/source4"
CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

src_prepare() {
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I. || die "eautoconf failed"
}

src_configure() {
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable debug) \
		--enable-developer \
		$(use_enable dso) \
		--disable-external-heimdal \
		--disable-external-libtalloc \
		--enable-external-libtdb \
		--disable-external-libtevent \
		--disable-external-libldb \
		--enable-fhs \
		--enable-largefile \
		$(use_enable gnutls) \
		$(use_enable netapi) \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--with-modulesdir=/usr/lib/samba/modules \
		--with-privatedir=/var/lib/samba/private \
		--with-ntp-signd-socket-dir=/var/run/samba \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--with-piddir=/var/run/samba \
		--without-included-popt \
		$(use_with sqlite sqlite3) \
		$(use_with threads pthreads) \
		--with-setproctitle
}

src_compile() {
	# compile libs
	emake basics || die "emake basics failed"
	emake libraries || die "emake libraries failed"
}

src_install() {
	# install libs
	emake installlib DESTDIR="${D}" || die "emake installib failed"
	emake installheader DESTDIR="${D}" || die "emake installheader failed"
}
