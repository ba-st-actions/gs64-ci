FROM ghcr.io/ba-st/gs64-rowan:v3.7.0

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh
RUN setcap cap_sys_resource=pe -r $GEMSTONE/sys/stoned
RUN setcap cap_sys_resource=pe -r $GEMSTONE/sys/pgsvrmain

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
