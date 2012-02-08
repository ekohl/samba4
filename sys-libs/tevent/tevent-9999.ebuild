# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"

inherit waf-utils python git-2

DESCRIPTION="Samba tevent library"
HOMEPAGE="http://tevent.samba.org/"
EGIT_REPO_URI="git://git.samba.org/samba.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-lang/python-2.4.2
	>=sys-libs/talloc-2.0.7[python]"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

WAF_BINARY="${WORKDIR}/buildtools/bin/waf"
S="${WORKDIR}/lib/tevent"
EGIT_SOURCEDIR="${WORKDIR}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}
