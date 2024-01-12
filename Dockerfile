FROM ghcr.io/ba-st/gs64-rowan:non_root_image

COPY stone-ci.sh /opt/gemstone/stone-ci.sh

USER root
RUN  apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
     libcap2-bin \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && setcap cap_sys_resource=pe $GEMSTONE/sys/stoned \
  && setcap cap_sys_resource=pe $GEMSTONE/sys/pgsvrmain \
  && setcap -r $GEMSTONE/sys/stoned \
  && setcap -r $GEMSTONE/sys/pgsvrmain \
  ;

USER ${GS_USER}

ENTRYPOINT [ "/opt/gemstone/stone-ci.sh" ]
