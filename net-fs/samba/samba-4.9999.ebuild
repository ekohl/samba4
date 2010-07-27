# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit confutils git

MY_PV="${PV/_alpha/alpha}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug gnutls fulltest"

DEPEND="!net-fs/samba-libs
	!net-fs/samba-server
	!net-fs/samba-client
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	>=dev-lang/python-2.4.2
	gnutls? ( >=net-libs/gnutls-1.4.0 )
	>=sys-libs/talloc-2.0.3
	>=sys-libs/tdb-1.2.2
	=sys-libs/tevent-0.9.9"
	#=sys-libs/ldb-0.9.11 No release yet
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}/source4"
PATH="${WORKDIR}/${MY_P}/buildtools/bin:$PATH"

pkg_setup() {
	confutils_use_depend_all fulltest test
}

src_unpack() {
	EGIT_REPO_URI="git://git.samba.org/samba.git" S="${WORKDIR}/${MY_P}" git_src_unpack
}

src_configure() {
	local myconf

	# $(use_enable debug developer), but --disable-developer doesn't work
	if use debug ; then
		myconf="${myconf} --enable-developer"
	fi
	
	# $(use_enable test selftest), but --disable-selftest doesn't work
	if use test ; then
		myconf="${myconf} --enable-selftest"
	fi

	waf configure -C \
		${myconf} \
		--bundled-libraries=ldb,NONE \
		--enable-fhs \
		$(use_enable gnutls) \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--with-modulesdir=/usr/lib/samba/modules \
		--with-privatedir=/var/lib/samba/private \
		--with-ntp-signd-socket-dir=/var/run/samba \
		--with-lockdir=/var/cache/samba \
		--with-piddir=/var/run/samba \
		--nopyc \
		--nopyo || die "configure failed"
}

src_compile() {
	waf build || die "build failed"
}

src_install() {
	waf install DESTDIR="${D}" || die "emake install failed"

	newinitd "${FILESDIR}/samba4.initd" samba
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
	python_mod_optimize $(python_get_sitedir)/${PN}

	# Warn that it's an alpha
	ewarn "Samba 4 is an alpha and therefore not considered stable. It's only"
	ewarn "meant to test and experiment and definitely not for production"
}

pkg_postrm() {
	# Clean up the python modules
	python_mod_cleanup
}
