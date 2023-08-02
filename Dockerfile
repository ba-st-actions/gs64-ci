FROM ghcr.io/ba-st/gs64-rowan:v3.6.6

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh
COPY post-action.sh /post-action.sh

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
