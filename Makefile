# New ports collection makefile for:	mikutter
# Date created:		2011-03-27
# Whom:			TAKATSU Tomonari <tota@FreeBSD.org>
#
# $FreeBSD$
#

PORTNAME=	mikutter
PORTVERSION=	0.0.3.3
CATEGORIES=	net-im ruby
MASTER_SITES=	http://mikutter.hachune.net/bin/
DISTNAME=	${PORTNAME}.${PORTVERSION}

MAINTAINER=	tota@FreeBSD.org
COMMENT=	A simple, powerful and moeful twitter client

RUN_DEPENDS=	${RUBY_SITEARCHLIBDIR}/gnome2.so:${PORTSDIR}/x11/ruby-gnome2 \
		${RUBY_PKGNAMEPREFIX}hmac>=0.3.2:${PORTSDIR}/security/ruby-hmac \
		rubygem-json_pure>=0:${PORTSDIR}/devel/rubygem-json_pure \
		${RUBY_SITELIBDIR}/escape.rb:${PORTSDIR}/textproc/ruby-escape \
		${RUBY_SITELIBDIR}/memoize.rb:${PORTSDIR}/devel/ruby-memoize \
		rubygem-oauth>=0:${PORTSDIR}/net/rubygem-oauth

WRKSRC=	${WRKDIR}/${PORTNAME}

LICENSE=        GPLv3
LICENSE_FILE=   ${WRKSRC}/LICENSE

USE_RUBY=	yes
NO_BUILD=	yes

RUBY_SHEBANG_FILES=	mikutter.rb \
			core/lib/piapro.rb

SUB_FILES=	mikutter.desktop
SUB_LIST=	RUBY_SITELIBDIR=${RUBY_SITELIBDIR}

PORTDOCS=	README

OPTIONS=	NOTIFY "notify-send support" on \
		HTTPCLIENT "httpclient support" on
#		SDL "SDL support" off

.include <bsd.port.pre.mk>

.if defined(WITH_NOTIFY)
RUN_DEPENDS+=	notify-send:${PORTSDIR}/devel/libnotify
.endif

.if defined(WITH_HTTPCLIENT)
RUN_DEPENDS+=	rubygem-httpclient>=0:${PORTSDIR}/www/rubygem-httpclient
.endif

#.if defined(WITH_SDL)
#RUN_DEPENDS+=	rubygem-sdl>=0:${PORTSDIR}/devel/rubygem-sdl
#.endif

post-patch:
	@${REINPLACE_CMD} -e 's|%%RUBY_SITELIBDIR%%|${RUBY_SITELIBDIR}|' \
		${WRKSRC}/mikutter.rb
	@${RM} -rf ${WRKSRC}/core/json*
	@${RM} -rf ${WRKSRC}/core/lib/escape.rb
	@${RM} -rf ${WRKSRC}/core/lib/memoize.rb
	@${RM} -rf ${WRKSRC}/core/lib/oauth*

do-install:
	@${INSTALL_SCRIPT} ${INSTALL_WRKSRC}/mikutter.rb ${PREFIX}/bin/mikutter
	@cd ${INSTALL_WRKSRC} \
		&& ${COPYTREE_SHARE} core ${RUBY_SITELIBDIR}/mikutter \
		&& ${COPYTREE_SHARE} plugin ${RUBY_SITELIBDIR}/mikutter
	@${INSTALL_DATA} ${WRKDIR}/${SUB_FILES} ${PREFIX}/share/applications/
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	@${INSTALL_DATA} ${WRKSRC}/${PORTDOCS} ${DOCSDIR}
.endif

x-generate-plist:
	${ECHO} bin/mikutter > pkg-plist.new
	${FIND} ${RUBY_SITELIBDIR}/mikutter -type f | ${SORT} | ${SED} -e 's,${RUBY_SITELIBDIR},%%RUBY_SITELIBDIR%%,' >> pkg-plist.new
	${ECHO} share/applications/mikutter.desktop >> pkg-plist.new
	${ECHO} @exec ${MKDIR:S|/bin/||} %D/%%RUBY_SITELIBDIR%%/mikutter/core/hatsunelisp >> pkg-plist.new
	${ECHO} @exec ${MKDIR:S|/bin/||} %D/%%RUBY_SITELIBDIR%%/mikutter/core/lib/json/ext >> pkg-plist.new
	${FIND} ${RUBY_SITELIBDIR}/mikutter -type d -depth | ${SORT} -r | ${SED} -e 's,${RUBY_SITELIBDIR},@dirrm %%RUBY_SITELIBDIR%%,' >> pkg-plist.new

.include <bsd.port.post.mk>
