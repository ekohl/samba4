# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools

MY_PV="${PV/_alpha/alpha}"
MY_P="samba-${MY_PV}"

DESCRIPTION="Library bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug dso gnutls +netapi sqlite threads tools"

DEPEND="!<net-fs/samba-3.3
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	caps? ( sys-libs/libcap )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )
	>=sys-libs/talloc-2.0.0
	>=sys-libs/tdb-1.2.0
	=sys-libs/tevent-0.9.8"
	#=sys-libs/ldb-0.9.10 No release yet
# See source4/min_versions.m4 for the minimal versions

RDEPEND="${DEPEND}"

RESTRICT="test mirror"

BINPROGS=""
if use tools ; then
	BINPROGS="${BINPROGS} bin/ldbedit bin/ldbsearch bin/ldbadd bin/ldbdel bin/ldbmodify bin/ldbrename"
fi

S="${WORKDIR}/${MY_P}/source4"

src_prepare() {
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I.
}

src_configure() {
	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf \
		--sysconfdir=/etc \
		--localstatedir=/var \
		$(use_enable debug) \
		--enable-developer \
		$(use_enable dso) \
		--disable-external-heimdal \
		--enable-external-libtalloc \
		--enable-external-libtdb \
		--enable-external-libtevent \
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
		--with-setproctitle \
		--with-readline
}

src_compile() {
	# compile libs
	emake basics || die "emake basics failed"
	emake libraries || die "emake libraries failed"
	if use tools && [[ -n "${BINPROGS}" ]] ; then
		emake ${BINPROGS} || die "emake tools failed"
	fi
}

src_install() {
	# install libs
	emake installlib DESTDIR="${D}" || die "emake installib failed"
	emake installheader DESTDIR="${D}" || die "emake installheader failed"
	if use tools && [[ -n "${BINPROGS}" ]] ; then
		dobin ${BINPROGS} || die "not all binaries around"
	fi
}
