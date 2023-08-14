FROM ghcr.io/ba-st/gs64-rowan:v3.6.6-2023-08-14

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
