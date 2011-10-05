# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit confutils python waf-utils

if use ldb ; then
	# For get_libdir
	inherit multilib
fi

MY_PV="${PV/_alpha/alpha}"
MY_P="${PN}-${MY_PV}"

if [ "${PV}" = "4.9999" ]; then
	EGIT_REPO_URI="git://git.samba.org/samba.git"
	inherit git-2
else
	SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
fi

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnutls fulltest +ldb"

DEPEND="!net-fs/samba-libs
	!net-fs/samba-server
	!net-fs/samba-client
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	>=dev-lang/python-2.4.2
	dev-python/subunit
	>=app-crypt/heimdal-1.5[-ssl]
	gnutls? ( >=net-libs/gnutls-1.4.0 )
	>=sys-libs/tdb-1.2.9[python]
	!ldb? ( >=sys-libs/ldb-1.1.2 )
	>=sys-libs/talloc-2.0.6[python]
	>=sys-libs/tevent-0.9.14"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}"

WAF_BINARY="${S}/buildtools/bin/waf"

pkg_setup() {
	confutils_use_depend_all fulltest test
}

src_configure() {
	local bundled="NONE"
	use ldb && bundled+=",ldb,pyldb-util"

	waf-utils_src_configure \
		--enable-fhs \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--disable-rpath \
		--disable-rpath-install \
		--nopyc \
		--nopyo \
		--bundled-libraries=$bundled \
		--builtin-libraries=replace,ccan \
		$(use_enable gnutls)
}

src_install() {
	waf-utils_src_install

	newinitd "${FILESDIR}/samba4.initd" samba || die "newinitd failed"

	#remove conflicting file for tevent profided by sys-libs/tevent
	find "${D}" -type f -name "_tevent.so" -exec rm -f {} \;

	if use ldb ; then
		#create a symlink to ldb lib for linking other packages using ldb
		dosym samba/libldb.so.1.1.2 usr/$(get_libdir)/libldb.so
	fi
}

src_test() {
	local extra_opts=""
	use fulltest || extra_opts+="--quick"
	"${WAF_BINARY}" test ${extra_opts} || die "test failed"
}

pkg_postinst() {
	# Optimize the python modules so they get properly removed
	python_mod_optimize "${PN}"

	einfo "See http://wiki.samba.org/index.php/Samba4/HOWTO for more"
	einfo "information about samba 4."

	# Warn that it's an alpha
	ewarn "Samba 4 is an alpha and therefore not considered stable. It's only"
	ewarn "meant to test and experiment and definitely not for production"
}

pkg_postrm() {
	# Clean up the python modules
	python_mod_cleanup "${PN}"
}
