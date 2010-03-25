# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://git.samba.org/${PN}.git"
	inherit git autotools
else
	SRC_URI="ftp://ftp.samba.org/pub/linux-cifs/${PN}/${P}.tar.bz2"
fi

DESCRIPTION="Tools for Managing Linux CIFS Client Filesystems"
HOMEPAGE="http://www.samba.org/linux-cifs/cifs-utils/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ads"

DEPEND="!net-fs/mount-cifs
	!net-fs/samba-client
	!<=net-fs/samba-3.5.0
	ads? ( sys-libs/talloc virtual/krb5 sys-apps/keyutils )"
RDEPEND="${DEPEND}"

src_prepare() {
	if [[ ${PV} == 9999 ]]; then
		eautoreconf || die "eautoreconf failed"
	fi
}

src_configure() {
	econf $(use_enable ads cifsupcall)
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
}
