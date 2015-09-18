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
ENV JMETER_HOME ${KIEKER_FOLDER}/jmeter
ENV JMETER_FOLDER /opt/jmeter

# Set other variables
ENV KIEKER_MONITORING_PROPERTIES kieker.monitoring.properties
ENV KIEKER_AGENT_JAR agent.jar
ENV KIEKER_JMETER_ZIP jmeter.zip
#ENV KIEKER_JMETER_USER_PROPS user.properties

COPY ${KIEKER_MONITORING_PROPERTIES} ${KIEKER_TMP_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES} 
COPY lib/* ${KIEKER_LIB_FOLDER}/

RUN \
  mkdir -p ${JMETER_FOLDER} && \
  mkdir -p ${JMETER_HOME} && \
  mkdir -p ${KIEKER_AGENT_FOLDER} && \
  mkdir -p ${KIEKER_LOGS_FOLDER}
  
ENV KIEKER_VERSION 1.12-20150918.004332-162
ENV KIEKER_AGENT_JAR_SRC kieker-${KIEKER_VERSION}-aspectj.jar
ENV KIEKER_AGENT_BASE_URL "https://oss.sonatype.org/content/groups/staging/net/kieker-monitoring/kieker/1.12-SNAPSHOT"
ENV KIEKER_JMETER_VERSION 2.13
ENV KIEKER_JMETER_NAME apache-jmeter-${KIEKER_JMETER_VERSION}
ENV KIEKER_JMETER_URL "http://apache.openmirror.de/jmeter/binaries/${KIEKER_JMETER_NAME}.zip"

RUN \
  wget -q "${KIEKER_AGENT_BASE_URL}/${KIEKER_AGENT_JAR_SRC}" -O "${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR}" && \
  wget -q "${KIEKER_JMETER_URL}" -O "${JMETER_FOLDER}/${KIEKER_JMETER_ZIP}" && \
  unzip -q ${JMETER_FOLDER}/${KIEKER_JMETER_ZIP} -d ${JMETER_FOLDER} && \
  cp -r ${JMETER_FOLDER}/${KIEKER_JMETER_NAME}/* ${JMETER_HOME} && \
  cp ${KIEKER_LIB_FOLDER}/* ${JMETER_HOME}/lib/. && \
  cp ${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR} ${JMETER_HOME}/lib/. && \
  sed -i '133i\'"export KIEKER_JAVA_OPTS=\" \
    -javaagent:${KIEKER_AGENT_FOLDER}/${KIEKER_AGENT_JAR} \
    -Dkieker.monitoring.configuration=${KIEKER_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES} \
    -Dkieker.monitoring.writer.filesystem.AsyncFsWriter.customStoragePath=${KIEKER_LOGS_FOLDER} \
    -Daj.weaving.verbose=true \
    -Dkieker.monitoring.skipDefaultAOPConfiguration=true \
    \"" ${JMETER_HOME}/bin/jmeter && \
  sed -i '136i\'"export ARGS=\"\${KIEKER_JAVA_OPTS} \${ARGS}\"" ${JMETER_HOME}/bin/jmeter

# Allow execution of jmeter scripts
RUN \
  chmod -R u+w ${JMETER_HOME} && \
  chmod +x ${JMETER_HOME}/bin/jmeter && \
  chmod +x ${JMETER_HOME}/bin/jmeter-server
  
# COPY jmeter/${KIEKER_JMETER_USER_PROPS} ${JMETER_HOME}/bin/
  
CMD \
  cp -nr ${KIEKER_TMP_CONFIG_FOLDER}/* ${KIEKER_CONFIG_FOLDER}/ && \
  rm ${KIEKER_TMP_CONFIG_FOLDER}/ -r && \
  cd ${JMETER_HOME}/bin && \
  ./jmeter-server -l ${KIEKER_LOGS_FOLDER}/jmeter.log
  
VOLUME ["/opt/kieker"]
  
  
  
