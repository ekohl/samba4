# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit confutils python

MY_PV="${PV/_alpha/alpha}"
MY_P="${PN}-${MY_PV}"

if [ "${PV}" = "4.9999" ]; then
	EGIT_REPO_URI="git://git.samba.org/samba.git"
	inherit git
else
	SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
fi

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnutls fulltest"

DEPEND="!net-fs/samba-libs
	!net-fs/samba-server
	!net-fs/samba-client
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	>=dev-lang/python-2.4.2
	gnutls? ( >=net-libs/gnutls-1.4.0 )
	!sys-libs/tdb" # Conflict because of tdb binaries
	#>=sys-libs/talloc-2.0.3 No 2.0.3 release
	#>=sys-libs/tdb-1.2.4 No 1.2.4 release
	#=sys-libs/tevent-0.9.9 System tevent wants system talloc
	#=sys-libs/ldb-0.9.11 No release yet
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}/source4"
PATH="${WORKDIR}/${MY_P}/buildtools/bin:$PATH"

pkg_setup() {
	confutils_use_depend_all fulltest test
}

src_unpack() {
	if [ "${PV}" = "4.9999" ]; then
		S="${WORKDIR}/${MY_P}" git_src_unpack
	else
		default
	fi
}

src_configure() {
	# FIXME add --jobs
	# Mostly copied from debian
	FLAGS="$CFLAGS" waf configure -C \
		--enable-fhs \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--with-piddir=/var/run \
		--with-privatedir=/var/lib/samba/private \
		--disable-rpath \
		--disable-rpath-install \
		--bundled-libraries=ldb,tdb,talloc,tevent,NONE \
		--builtin-libraries=replace \
		--nopyc \
		--nopyo \
		$(use_enable gnutls) \
		|| die "configure failed"
}

src_compile() {
	waf build || die "build failed"
}

src_install() {
	DESTDIR="${D}" waf install || die "emake install failed"

	newinitd "${FILESDIR}/samba4.initd" samba || die "newinitd failed"
}

src_test() {
	if use fulltest ; then
		waf test || die "test failed"
	else
		waf test --quick || die "Test failed"
	fi
}

pkg_postinst() {
	# Optimize the python modules so they get properly removed
	python_mod_optimize "${PN}"

	# Warn that it's an alpha
	ewarn "Samba 4 is an alpha and therefore not considered stable. It's only"
	ewarn "meant to test and experiment and definitely not for production"
}

pkg_postrm() {
	# Clean up the python modules
	python_mod_cleanup "${PN}"
}
