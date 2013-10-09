plugin_name = tomcat7-plugin
publish_bucket = cloudbees-clickstack
publish_repo = testing
publish_url = s3://$(publish_bucket)/$(publish_repo)/

deps = lib/tomcat7.zip \
       lib/genapp-setup-tomcat7.jar \
       lib/cloudbees-jmx-invoker-jar-with-dependencies.jar \
       lib/jmxtrans-agent.jar \
       lib/cloudbees-web-container-extras.jar

pkg_files = control functions server setup lib java conf

include plugin.mk

tomcat7_ver = 7.0.42
tomcat7_src = http://archive.apache.org/dist/tomcat/tomcat-7/v$(tomcat7_ver)/bin/apache-tomcat-$(tomcat7_ver).zip
tomcat7_md5 = b6aebcbb5c026e157f2d8e33e9ad6f79

lib/tomcat7.zip:
	$(call get-file,$@,$(tomcat7_src),$(tomcat7_md5))
	$(call repackage-tomcat7)

repackage-tomcat7 = @ \
    unzip -qd lib lib/tomcat7.zip; \
    rm -rf lib/apache-tomcat-*/webapps; \
    rm lib/tomcat7.zip; \
    cd lib/apache-tomcat-*; \
    zip -rqy ../tomcat7.zip *; \
    cd ../..; \
    rm -rf lib/apache-tomcat-$(tomcat7_ver)

	cd genapp-setup-tomcat7; \
	mvn -q clean test assembly:single; \
	cd target; \
	cp genapp-setup-tomcat7-*-jar-with-dependencies.jar \
	$(CURDIR)/lib/genapp-setup-tomcat7.jar

jmxtrans_agent_ver = 1.0.6
jmxtrans_agent_url = http://repo1.maven.org/maven2/org/jmxtrans/agent/jmxtrans-agent/$(jmxtrans_agent_ver)/jmxtrans-agent-$(jmxtrans_agent_ver).jar
jmxtrans_agent_md5 = 58be0f2268d4dfd59fb10b8eab27ec7f

lib/jmxtrans-agent.jar: | lib
	mkdir -p lib
	curl -fLo lib/jmxtrans-agent.jar "$(jmxtrans_agent_url)"
	$(call check-md5,lib/jmxtrans-agent.jar,$(jmxtrans_agent_md5))

jmx_invoker_ver = 1.0.2
jmx_invoker_src = http://repo1.maven.org/maven2/com/cloudbees/cloudbees-jmx-invoker/$(jmx_invoker_ver)/cloudbees-jmx-invoker-$(jmx_invoker_ver)-jar-with-dependencies.jar
jmx_invoker_md5 = c880f7545775529cfce6ea6b67277453

lib/cloudbees-jmx-invoker-jar-with-dependencies.jar: | lib
	mkdir -p lib
	curl -fLo lib/cloudbees-jmx-invoker-jar-with-dependencies.jar "$(jmx_invoker_src)"
	$(call check-md5,lib/cloudbees-jmx-invoker-jar-with-dependencies.jar,$(jmx_invoker_md5))

cloudbees_web_container_extras_ver = 1.0.1
cloudbees_web_container_extras_src = http://repo1.maven.org/maven2/com/cloudbees/cloudbees-web-container-extras/$(cloudbees_web_container_extras_ver)/cloudbees-web-container-extras-$(cloudbees_web_container_extras_ver).jar
cloudbees_web_container_extras_md5 = c63a49c5a8071a0616c6696c3e6ed32a

lib/cloudbees-web-container-extras.jar: | lib
	mkdir -p lib
	curl -fLo lib/cloudbees-web-container-extras.jar "$(cloudbees_web_container_extras_src)"
	$(call check-md5,lib/cloudbees-web-container-extras.jar,$(cloudbees_web_container_extras_md5))
