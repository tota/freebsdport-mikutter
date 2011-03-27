--- mikutter.rb.orig	2011-01-15 16:13:35.000000000 +0900
+++ mikutter.rb	2011-03-27 09:30:23.000000000 +0900
@@ -12,7 +12,7 @@
 
 =end
 
-Dir.chdir(File.join(File.dirname($0), 'core'))
+Dir.chdir('%%RUBY_SITELIBDIR%%/mikutter/core')
 
 require File.expand_path('utils')
 miquire :core, 'environment'
