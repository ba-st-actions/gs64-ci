FROM ghcr.io/ba-st/gs64-rowan:v3.6.6

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh
COPY cleanup.sh /cleanup.sh

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
