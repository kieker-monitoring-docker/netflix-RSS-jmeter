FROM java:7

MAINTAINER http://kieker-monitoring.net/support/

WORKDIR /opt

EXPOSE 1099 4000

# Set folder variables
ENV KIEKER_FOLDER /opt/kieker
ENV KIEKER_AGENT_FOLDER ${KIEKER_FOLDER}/agent
ENV KIEKER_CONFIG_FOLDER ${KIEKER_FOLDER}/config
ENV KIEKER_TMP_CONFIG_FOLDER ${KIEKER_FOLDER}/tmp-config
ENV KIEKER_LOGS_FOLDER ${KIEKER_FOLDER}/logs
ENV KIEKER_LIB_FOLDER ${KIEKER_FOLDER}/lib
ENV KIEKER_JMETER_FOLDER ${KIEKER_FOLDER}/jmeter

# Set other variables
ENV KIEKER_MONITORING_PROPERTIES kieker.monitoring.properties
ENV KIEKER_AGENT_JAR agent.jar
ENV KIEKER_JMETER_ZIP jmeter.zip
ENV KIEKER_JMETER_TESTPLAN TestPlan.jmx
ENV KIEKER_JMETER_USER_PROPS user.properties

ENV KIEKER_JMETER_VERSION 2.13
ENV KIEKER_JMETER_NAME apache-jmeter-${KIEKER_JMETER_VERSION}
ENV KIEKER_JMETER_URL "http://apache.openmirror.de/jmeter/binaries/${KIEKER_JMETER_NAME}.zip"
ENV JMETER_HOME /opt/${KIEKER_JMETER_NAME}

COPY ${KIEKER_MONITORING_PROPERTIES} ${KIEKER_TMP_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES} 
COPY jmeter/${KIEKER_JMETER_TESTPLAN} ${KIEKER_TMP_CONFIG_FOLDER}/${KIEKER_JMETER_TESTPLAN}
COPY jmeter/${KIEKER_JMETER_USER_PROPS} ${JMETER_HOME}/bin/.
COPY lib/* ${KIEKER_LIB_FOLDER}/

RUN \
  mkdir -p ${KIEKER_AGENT_FOLDER} && \
  mkdir -p ${KIEKER_JMETER_FOLDER} && \
  mkdir -p ${KIEKER_LOGS_FOLDER}
  
ENV KIEKER_VERSION 1.12-20150821.004342-137
ENV KIEKER_AGENT_JAR_SRC kieker-${KIEKER_VERSION}-aspectj.jar
ENV KIEKER_AGENT_BASE_URL "https://oss.sonatype.org/content/groups/staging/net/kieker-monitoring/kieker/1.12-SNAPSHOT"
ENV KIEKER_JMETER_VERSION 2.13
ENV KIEKER_JMETER_NAME apache-jmeter-${KIEKER_JMETER_VERSION}
ENV KIEKER_JMETER_URL "http://apache.openmirror.de/jmeter/binaries/${KIEKER_JMETER_NAME}.zip"
ENV JMETER_HOME /opt/${KIEKER_JMETER_NAME}

RUN \
  wget -q "${KIEKER_AGENT_BASE_URL}/${KIEKER_AGENT_JAR_SRC}" -O "${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR}" && \
  wget -q "${KIEKER_JMETER_URL}" -O "${KIEKER_JMETER_FOLDER}/${KIEKER_JMETER_ZIP}" && \
  unzip -q ${KIEKER_JMETER_FOLDER}/${KIEKER_JMETER_ZIP} -d /opt && \
  rm ${KIEKER_JMETER_FOLDER}/${KIEKER_JMETER_ZIP} && \
  cp ${KIEKER_LIB_FOLDER}/* ${JMETER_HOME}/lib/. && \
  cp ${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR} ${JMETER_HOME}/lib/. && \
  sed -i '133i\'"export KIEKER_JAVA_OPTS=\" \
    -javaagent:${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR} \
    -Dkieker.monitoring.configuration=${KIEKER_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES} \
    -Dkieker.monitoring.writer.filesystem.AsyncFsWriter.customStoragePath=${KIEKER_LOGS_FOLDER} \
    -Daj.weaving.verbose=true \
    -Dkieker.monitoring.skipDefaultAOPConfiguration=true \
    \"" ${JMETER_HOME}/bin/jmeter && \
      sed -i '136i\'"export ARGS=\"\${KIEKER_JAVA_OPTS} \${ARGS}\"" ${JMETER_HOME}/bin/jmeter && \
  chmod +x ${JMETER_HOME}/bin/jmeter && \
  chmod +x ${JMETER_HOME}/bin/jmeter-server
  
CMD \
  cp -nr ${KIEKER_TMP_CONFIG_FOLDER}/* ${KIEKER_CONFIG_FOLDER}/ && \
  rm ${KIEKER_TMP_CONFIG_FOLDER}/ -r && \
  ${JMETER_HOME}/bin/jmeter-server
  
VOLUME ["/opt/kieker"]
  
  
  
