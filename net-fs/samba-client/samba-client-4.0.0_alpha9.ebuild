# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils

MY_PV="${PV/_alpha/alpha}"
MY_P="samba-${MY_PV}"

DESCRIPTION="Client bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps debug threads"

DEPEND="!<net-fs/samba-3.3
	!net-fs/mount-cifs
	dev-libs/popt
	dev-libs/iniparser
	virtual/libiconv
	caps? ( sys-libs/libcap )
	~net-fs/samba-libs-${PV}[caps?,netapi,threads?]
	>=sys-libs/talloc-2.0.0
	=sys-libs/tevent-0.9.8
	"
	#>=sys-libs/tdb-1.1.7 https://bugzilla.samba.org/show_bug.cgi?id=6948
	#=sys-libs/ldb-0.9.9 No release yet
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
	local myconf

	# Filter out -fPIE
	[[ ${CHOST} == *-*bsd* ]] && myconf="${myconf} --disable-pie"
	use hppa && myconf="${myconf} --disable-pie"

	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || ac_cv_header_sys_capability_h=no

	econf ${myconf} \
		--sysconfdir=/etc \
		--localstatedir=/var \
		$(use_enable debug developer) \
		--enable-largefile \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--enable-fhs \
		$(use_with threads pthreads) \
		--with-privatedir=/var/lib/samba/private \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--disable-external-heimdal \
		--enable-external-libtalloc \
		--disable-external-libtdb \
		--enable-external-libtevent \
		--disable-external-libldb \
		--enable-netapi \
		--without-included-popt
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
