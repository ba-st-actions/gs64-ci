FROM ghcr.io/ba-st/gs64-rowan:v3.7.0

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh

RUN  apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
     libcap2-bin \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#  && setcap cap_sys_resource=pe $GEMSTONE/sys/stoned \
#  && setcap cap_sys_resource=pe $GEMSTONE/sys/pgsvrmain \
#  && setcap -r $GEMSTONE/sys/stoned \
  && setcap -r $GEMSTONE/sys/pgsvrmain \
  ;

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
