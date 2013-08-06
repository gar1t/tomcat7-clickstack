plugin_name = tomcat7-plugin
publish_bucket = cloudbees-clickstack
publish_repo = testing
publish_url = s3://$(publish_bucket)/$(publish_repo)/

deps = lib/tomcat7.zip lib/cloudbees-jmx-invoker.jar lib/jmxtrans-agent.jar lib/cloudbees-web-container-extras.jar

pkg_files = control functions server setup lib java conf

include plugin.mk

lib:
	mkdir -p lib

deps:
	cd java; make deps

clean:
	rm -rf lib
	cd java; make clean

tomcat7_ver = 7.0.42
tomcat7_url = http://archive.apache.org/dist/tomcat/tomcat-7/v$(tomcat7_ver)/bin/apache-tomcat-$(tomcat7_ver).zip
tomcat7_md5 = bf430c73797f5c0ef6c7f40fad5d7833

lib/tomcat7.zip: lib lib/genapp-setup-tomcat7.jar
	curl -fLo lib/tomcat7.zip "$(tomcat7_url)"
	unzip -qd lib lib/tomcat7.zip
	rm -rf lib/apache-tomcat-$(tomcat7_ver)/webapps
	rm lib/tomcat7.zip
	cd lib/apache-tomcat-$(tomcat7_ver); \
	zip -rqy ../tomcat7.zip *
	rm -rf lib/apache-tomcat-$(tomcat7_ver)

JAVA_SOURCES := $(shell find genapp-setup-tomcat7/src -name "*.java")
JAVA_JARS = $(shell find genapp-setup-tomcat7/target -name "*.jar")

lib/genapp-setup-tomcat7.jar: $(JAVA_SOURCES) $(JAVA_JARS) lib
	cd genapp-setup-tomcat7; \
	mvn -q clean test assembly:single; \
	cd target; \
	cp genapp-setup-tomcat7-*-jar-with-dependencies.jar \
	$(CURDIR)/lib/genapp-setup-tomcat7.jar

jmxtrans_agent_ver = 1.0.0
jmxtrans_agent_url = http://repo1.maven.org/maven2/org/jmxtrans/agent/jmxtrans-agent/$(jmxtrans_agent_ver)/jmxtrans-agent-$(jmxtrans_agent_ver).jar
jmxtrans_agent_md5 = 9dd2bdd2adb7df9dbae093a2c6b08678

lib/jmxtrans-agent.jar: lib
	mkdir -p lib
	curl -fLo lib/jmxtrans-agent.jar "$(jmxtrans_agent_url)"
	$(call check-md5,lib/jmxtrans-agent.jar,$(jmxtrans_agent_md5))

jmx_invoker_ver = 1.0.2
jmx_invoker_src = http://repo1.maven.org/maven2/com/cloudbees/cloudbees-jmx-invoker/$(jmx_invoker_ver)/cloudbees-jmx-invoker-$(jmx_invoker_ver)-jar-with-dependencies.jar
jmx_invoker_md5 = c880f7545775529cfce6ea6b67277453

lib/cloudbees-jmx-invoker.jar: lib
	mkdir -p lib
	curl -fLo lib/cloudbees-jmx-invoker-jar-with-dependencies.jar "$(jmx_invoker_src)"
	$(call check-md5,lib/cloudbees-jmx-invoker-jar-with-dependencies.jar,$(jmx_invoker_md5))

cloudbees_web_container_extras_ver = 1.0.0
cloudbees_web_container_extras_src = http://repo1.maven.org/maven2/com/cloudbees/cloudbees-web-container-extras/$(cloudbees_web_container_extras_ver)/cloudbees-web-container-extras-$(cloudbees_web_container_extras_ver).jar
cloudbees_web_container_extras_md5 = 6757957008d09050f3e4352a827d876c

lib/cloudbees-web-container-extras.jar: lib
	mkdir -p lib
	curl -fLo lib/cloudbees-web-container-extras.jar "$(cloudbees_web_container_extras_src)"
	$(call check-md5,lib/cloudbees-web-container-extras.jar,$(cloudbees_web_container_extras_md5))
