# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/tdb/tdb-1.2.7-r1.ebuild,v 1.8 2011/04/25 14:33:46 armin76 Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"

inherit python eutils

DESCRIPTION="Samba tdb"
HOMEPAGE="http://tdb.samba.org/"
SRC_URI="http://samba.org/ftp/tdb/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="python static-libs tools tdbtest"

RDEPEND=""
DEPEND="!<net-fs/samba-3.4
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-libs/popt"

WAF="${WORKDIR}/${P}/buildtools/bin/waf"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_configure() {
	$WAF configure --prefix=/usr/ || die "configure failed"
}

src_compile() {
	$WAF build || die "build failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"

	dodoc docs/README

	use static-libs || rm -f "${D}"/usr/lib*/*.a
	use tools || rm -rf "${D}/usr/bin" "${D}/usr/share/man"
	use tdbtest && dobin bin/tdbtest
	use python && python_need_rebuild
}

src_test() {
	# the default src_test runs 'make test' and 'make check', letting
	# the tests fail occasionally (reason: unknown)
	emake check || die "emake check failed"
}
