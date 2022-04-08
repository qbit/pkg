MAN=	pkg.8
SCRIPT=	pkg.pl

BINDIR?=	/usr/local/sbin
MANDIR?=	/usr/local/man/man

realinstall:
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
		${.CURDIR}/${SCRIPT} ${DESTDIR}${BINDIR}/pkg

readme: pkg.8
	mandoc -T markdown pkg.8 >README.md

regress: check-n-tidy

check-n-tidy:
	@perl -c pkg.pl
	@perltidy pkg.pl -st | diff -q pkg.pl -
	@mandoc -T lint -W style pkg.8
	@mandoc -T markdown pkg.8 | diff -q README.md -


.include <bsd.prog.mk>
