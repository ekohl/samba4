# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit pam confutils versionator multilib autotools

MY_PV="${PV/_alpha/alpha}"
MY_P="samba-${MY_PV}"

DESCRIPTION="Library bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug dso gnutls +netapi sqlite threads"

DEPEND="dev-libs/popt
	sys-libs/readline
	>=sys-libs/talloc-1.3.0
	>=sys-libs/tdb-1.1.5
	virtual/libiconv
	caps? ( sys-libs/libcap )
	debug? ( dev-libs/dmalloc )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )"

RDEPEND="${DEPEND}"

RESTRICT="test"

S="${WORKDIR}/${MY_P}/source4"
CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

src_prepare() {
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I. || die "eautoconf failed"
}

src_configure() {
	local myconf

	# No external heimdal for now due to unmerged upstream patches
	#if has_version app-crypt/heimdal ; then
	#	myconf="${myconf} --enable-external-heimdal"
	#elif has_version app-crypt/mit-krb5 ; then
	#	die "MIT Kerberos not supported by samba 4, use heimdal"
	#else
	#	myconf="${myconf} --disable-external-heimdal"
	#fi
	myconf="${myconf} --disable-external-heimdal"

	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf ${myconf} \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable debug) \
		--enable-developer \
		$(use_enable dso) \
		--enable-external-libtalloc \
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
	emake installheader DESTDIR="${D}" || die "emake installheaders failed"
}
