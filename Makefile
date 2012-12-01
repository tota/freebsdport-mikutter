# Created by: TAKATSU Tomonari <tota@FreeBSD.org>
# $FreeBSD: ports/net-im/mikutter/Makefile,v 1.20 2012/11/17 06:00:28 svnexp Exp $

PORTNAME=	mikutter
PORTVERSION=	0.2.0.1054
CATEGORIES=	net-im ruby
MASTER_SITES=	http://mikutter.hachune.net/bin/ \
		LOCAL
MASTER_SITE_SUBDIR=	tota/${PORTNAME}
DISTNAME=	${PORTNAME}.${PORTVERSION}

MAINTAINER=	tota@FreeBSD.org
COMMENT=	Simple, powerful, and moeful Twitter client

LICENSE=	GPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

INSTALL_DEPENDS=	${RUBY_SITEARCHLIBDIR}/gtk2.so:${PORTSDIR}/x11-toolkits/ruby-gtk2
RUN_DEPENDS=	${RUBY_SITEARCHLIBDIR}/gtk2.so:${PORTSDIR}/x11-toolkits/ruby-gtk2 \
		${RUBY_SITEARCHLIBDIR}/cairo.so:${PORTSDIR}/graphics/ruby-cairo \
		${RUBY_PKGNAMEPREFIX}hmac>=0.4.0:${PORTSDIR}/security/ruby-hmac \
		rubygem-json_pure>=0:${PORTSDIR}/devel/rubygem-json_pure \
		${RUBY_SITELIBDIR}/memoize.rb:${PORTSDIR}/devel/ruby-memoize \
		rubygem-oauth>=0:${PORTSDIR}/net/rubygem-oauth \
		${RUBY_SITELIBDIR}/bsearch.rb:${PORTSDIR}/devel/ruby-bsearch

WRKSRC=	${WRKDIR}/${PORTNAME}

USE_RUBY=	yes
RUBY_VER=	1.9
NO_BUILD=	yes

CONFLICTS=	mikutter-0.0.3.*

RUBY_SHEBANG_FILES=	mikutter.rb \
			core/autotag.rb \
			core/chi.rb \
			core/initialize.rb \
			core/lib/piapro.rb \
			core/miku/miku.rb

SUB_FILES=	mikutter.desktop
SUB_LIST=	RUBY_SITELIBDIR=${RUBY_SITELIBDIR}

PORTDOCS=	README

OPTIONS_DEFINE=		HTTPCLIENT NOTIFY
HTTPCLIENT_DESC=	httpclient support
NOTIFY_DESC=		notify-send support

OPTIONS_DEFAULT=	${OPTIONS_DEFINE}

.include <bsd.port.pre.mk>

.if ${RUBY_DEFAULT_VER} != ${RUBY_VER}
IGNORE=	requires RUBY_DEFAULT_VER=${RUBY_VER}
.endif

.if ${PORT_OPTIONS:MHTTPCLIENT}
RUN_DEPENDS+=	rubygem-httpclient>=0:${PORTSDIR}/www/rubygem-httpclient
.endif

.if ${PORT_OPTIONS:MNOTIFY}
RUN_DEPENDS+=	notify-send:${PORTSDIR}/devel/libnotify
.endif

post-patch:
	@${REINPLACE_CMD} -e "s|chdir\(.*\)|chdir\('${RUBY_SITELIBDIR}/mikutter/core'\)|" \
		${WRKSRC}/mikutter.rb
	@${REINPLACE_CMD} -i '' -e "s|miquire :lib, 'ruby-bsearch-1.5/bsearch'|require 'bsearch'|" \
		${WRKSRC}/core/mui/cairo_inner_tl.rb
	@${RM} -rf ${WRKSRC}/core/lib/hmac*
	@${RM} -rf ${WRKSRC}/core/lib/json*
	@${RM} -rf ${WRKSRC}/core/lib/memoize.rb
	@${RM} -rf ${WRKSRC}/core/lib/oauth*
	@${RM} -rf ${WRKSRC}/core/lib/ruby-bsearch-1.5

do-install:
	@${INSTALL_SCRIPT} ${INSTALL_WRKSRC}/mikutter.rb ${PREFIX}/bin/mikutter
	@cd ${INSTALL_WRKSRC} \
		&& ${COPYTREE_SHARE} core ${RUBY_SITELIBDIR}/mikutter \
		&& ${COPYTREE_SHARE} plugin ${RUBY_SITELIBDIR}/mikutter
	@${MKDIR} ${PREFIX}/share/applications
	@${INSTALL_DATA} ${WRKDIR}/${SUB_FILES} ${PREFIX}/share/applications/
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	@${INSTALL_DATA} ${INSTALL_WRKSRC}/${PORTDOCS} ${DOCSDIR}
.endif

x-generate-plist:
	${ECHO} bin/mikutter > pkg-plist.new
	${FIND} ${RUBY_SITELIBDIR}/mikutter -type f | ${SORT} | ${SED} -e 's,${RUBY_SITELIBDIR},%%RUBY_SITELIBDIR%%,' >> pkg-plist.new
	${ECHO} share/applications/mikutter.desktop >> pkg-plist.new
	${ECHO} '@dirrmtry share/applications' >> pkg-plist.new
	${FIND} ${RUBY_SITELIBDIR}/mikutter -type d -depth | ${SORT} -r | ${SED} -e 's,${RUBY_SITELIBDIR},@dirrm %%RUBY_SITELIBDIR%%,' >> pkg-plist.new

.include <bsd.port.post.mk>
