# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
PYTHON_DEPEND="2"

inherit waf-utils python multilib

DESCRIPTION="A simple database API"
HOMEPAGE="http://ldb.samba.org/"
SRC_URI="http://samba.org/ftp/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND=""
DEPEND="dev-lang/python
	app-text/docbook-xml-dtd:4.2
	>=sys-libs/tdb-1.2.9[python]
	>=sys-libs/talloc-2.0.7[python]
	>=sys-libs/tevent-0.9.14"

WAF_BINARY="${S}/buildtools/bin/waf"

RESTRICT="test" # broken

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_configure() {
	waf-utils_src_configure \
		--disable-rpath-install \
		--builtin-libraries=ccan,replace,tdb_compat \
		--bundled-libraries=NONE \
		--libdir=/usr/$(get_libdir) \
		--with-modulesdir=/usr/$(get_libdir)/ldb/modules
}

src_install() {
	waf-utils_src_install

	find "${D}" -type f -name _tevent.so -exec rm -f {} \;
}

src_test() {
	# Broken: ldb: unable to stat module /usr/lib64/ldb/modules/ldb : No such
	# file or directory
	echo "\"${WAF_BINARY}\" test"
	"${WAF_BINARY}" test || die "build failed"
}
