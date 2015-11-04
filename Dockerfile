FROM java:7

MAINTAINER http://kieker-monitoring.net/support/

WORKDIR /opt

EXPOSE 1099 4000

# Set folder variables
ENV KIEKER_FOLDER /opt/kieker
ENV KIEKER_CONFIG_FOLDER ${KIEKER_FOLDER}/config
ENV KIEKER_LOGS_FOLDER ${KIEKER_FOLDER}/logs
ENV KIEKER_BIN_FOLDER ${KIEKER_FOLDER}/bin
ENV KIEKER_LIB_FOLDER ${KIEKER_FOLDER}/lib
ENV JMETER_HOME ${KIEKER_FOLDER}/jmeter
ENV JMETER_FOLDER /opt/jmeter

# Set other variables
ENV KIEKER_MONITORING_PROPERTIES kieker.monitoring.properties
ENV KIEKER_JMETER_ZIP jmeter.zip  
ENV KIEKER_BIN_ZIP kieker.zip
#ENV KIEKER_JMETER_USER_PROPS user.properties

RUN \
  mkdir -p ${JMETER_FOLDER} && \
  mkdir -p ${JMETER_HOME} && \
  mkdir -p ${KIEKER_LOGS_FOLDER} && \
  mkdir -p ${KIEKER_CONFIG_FOLDER} && \
  mkdir -p ${KIEKER_BIN_FOLDER} && \
  echo "kieker.monitoring.writer.filesystem.AsyncFsWriter.customStoragePath = ${KIEKER_LOGS_FOLDER}" > ${KIEKER_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES}
  
ENV KIEKER_VERSION 1.13-SNAPSHOT
ENV KIEKER_BIN_ZIP_URL "http://build.se.informatik.uni-kiel.de/jenkins/job/kieker-nightly-release/lastSuccessfulBuild/artifact/build/distributions/kieker-${KIEKER_VERSION}-binaries.zip"
ENV KIEKER_JMETER_VERSION 2.13
ENV KIEKER_JMETER_NAME apache-jmeter-${KIEKER_JMETER_VERSION}
ENV KIEKER_JMETER_URL "http://apache.openmirror.de/jmeter/binaries/${KIEKER_JMETER_NAME}.zip"

RUN \
  wget -q "${KIEKER_BIN_ZIP_URL}" -O "${KIEKER_BIN_FOLDER}/${KIEKER_BIN_ZIP}" && \
  unzip "${KIEKER_BIN_FOLDER}/${KIEKER_BIN_ZIP}" \
    -d ${KIEKER_BIN_FOLDER} \
    kieker-${KIEKER_VERSION}/bin/* \
    kieker-${KIEKER_VERSION}/lib/* \
    kieker-${KIEKER_VERSION}/build/* && \
  rm "${KIEKER_BIN_FOLDER}/${KIEKER_BIN_ZIP}" && \
  wget -q "${KIEKER_JMETER_URL}" -O "${JMETER_FOLDER}/${KIEKER_JMETER_ZIP}" && \
  unzip -q ${JMETER_FOLDER}/${KIEKER_JMETER_ZIP} -d ${JMETER_FOLDER} && \
  cp -r ${JMETER_FOLDER}/${KIEKER_JMETER_NAME}/* ${JMETER_HOME} && \
  rm ${JMETER_FOLDER} -r


# Allow execution of jmeter scripts
RUN \
  chmod -R u+w ${JMETER_HOME} && \
  chmod +x ${JMETER_HOME}/bin/jmeter && \
  chmod +x ${JMETER_HOME}/bin/jmeter-server
  
# COPY jmeter/${KIEKER_JMETER_USER_PROPS} ${JMETER_HOME}/bin/
  
CMD \
  (${KIEKER_BIN_FOLDER}/kieker-${KIEKER_VERSION}/bin/resourceMonitor.sh -c ${KIEKER_CONFIG_FOLDER}/${KIEKER_MONITORING_PROPERTIES} &) && \
  (${JMETER_HOME}/bin/jmeter-server -l ${KIEKER_LOGS_FOLDER}/jmeter.log)
  
VOLUME ["/opt/kieker"]
  
  
  
