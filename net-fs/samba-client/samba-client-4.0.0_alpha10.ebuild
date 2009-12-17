# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools

MY_PV="${PV/_alpha/alpha}"
MY_PN="samba"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Client bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug dso gnutls +netapi sqlite threads"

DEPEND="!<net-fs/samba-3.3
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	caps? ( sys-libs/libcap )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )
	!net-fs/mount-cifs
	~net-fs/samba-libs-${PV}[caps?,debug?,dso?,gnutls?,netapi?,sqlite?,threads?]
	>=sys-libs/talloc-2.0.0
	>=sys-libs/tdb-1.2.0
	=sys-libs/tevent-0.9.8"
	#=sys-libs/ldb-0.9.10 No release yet
# See source4/min_versions.m4 for the minimal versions
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/source4"

RESTRICT="test mirror"

SBINPROGS="bin/mount.cifs bin/umount.cifs"
BINPROGS="bin/smbclient bin/net bin/nmblookup bin/ntlm_auth"

src_prepare() {
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace
}

src_configure() {
	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || ac_cv_header_sys_capability_h=no

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
		--with-privatedir=/var/lib/samba/private \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--without-included-popt \
		$(use_with sqlite sqlite3) \
		$(use_with threads pthreads) \
		--with-setproctitle \
		--with-readline
}

src_compile() {
	emake basics || die "emake basics failed"
	emake ${SBINPROGS} || die "emake sbinprogs failed"
	emake ${BINPROGS} || die "emake binprogs failed"
}

src_install() {
	into /
	dosbin ${SBINPROGS} || die "not all sbins around"

	into /usr
	dobin ${BINPROGS} || die "not all bins around"

	# FIXME: No docs in this release?
	#for prog in ${SBINPROGS} ${BINPROGS} ; do
	#	doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
	#	dohtml ../docs/htmldocs/manpages/${prog/bin\/}*.html || die "dohtml failed"
	#done
}
