FROM ghcr.io/ba-st/gs64-rowan:v3.6.6

COPY start-gemstone.sh /opt/gemstone/start-gemstone.sh
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

ENTRYPOINT [ "/opt/gemstone/entrypoint.sh" ]
