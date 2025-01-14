<clickhouse>
    <logger>
        <level>debug</level>
        <log>/var/log/clickhouse-server/clickhouse-server.log</log>
        <errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>3</count>
    </logger>
    <display_name>${cluster_name} ${node_name}</display_name>
    <http_port>8123</http_port>
    <listen_host>0.0.0.0</listen_host>
    <tcp_port>9000</tcp_port>
</clickhouse>