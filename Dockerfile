FROM totvsengpro/appserver-dev

EXPOSE 1234 8080 8081 9090

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -sSf http://localhost:8080 > /dev/null || exit 1

CMD ["/opt/totvs/appserver/appserver", "-console", "-config=/opt/totvs/appserver/appserver.ini"]
