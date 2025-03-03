<clickhouse>
    <logger>
        <level>debug</level>
        <log>/var/log/clickhouse-server/clickhouse-server.log</log>
        <errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>3</count>
    </logger>

    <display_name>${cluster_name} ${node_name}</display_name>

    <listen_host>0.0.0.0</listen_host>

    # HTTP configuration removal when encryption is enabled
    %{ if enable_encryption }
    <http_port remove="remove"/>
    <interserver_http_port remove="remove"/>
    %{ endif }

    # Secure ports configuration
    %{ if enable_encryption }
    <https_port>${https_port}</https_port>
    <tcp_port_secure>${tcp_port_secure}</tcp_port_secure>
    <interserver_https_port>${interserver_https_port}</interserver_https_port>
    %{ else }
    <http_port>${http_port}</http_port>
    <tcp_port>${tcp_port}</tcp_port>
    <interserver_http_port>${interserver_http_port}</interserver_http_port>
    %{ endif }

    <prometheus_port>${prometheus_port}</prometheus_port>

    # Disable emulation ports
    <!--mysql_port>9004</mysql_port-->
    <!--postgresql_port>9005</postgresql_port-->

    %{ if enable_encryption }
    <openSSL>
        <server>
            <certificateFile>/etc/clickhouse-server/server.crt</certificateFile>
            <privateKeyFile>/etc/clickhouse-server/server.key</privateKeyFile>
            <verificationMode>relaxed</verificationMode>
            <caConfig>/etc/clickhouse-server/ca.crt</caConfig>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
        </server>
        <client>
            <loadDefaultCAFile>true</loadDefaultCAFile>
            <caConfig>/etc/clickhouse-server/ca.crt</caConfig>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
            <verificationMode>relaxed</verificationMode>
            <invalidCertificateHandler>
                <name>RejectCertificateHandler</name>
            </invalidCertificateHandler>
        </client>
    </openSSL>

    <grpc>
        <enable_ssl>1</enable_ssl>
        <ssl_cert_file>/etc/clickhouse-server/server.crt</ssl_cert_file>
        <ssl_key_file>/etc/clickhouse-server/server.key</ssl_key_file>
        <ssl_require_client_auth>true</ssl_require_client_auth>
        <ssl_ca_cert_file>/etc/clickhouse-server/ca.crt</ssl_ca_cert_file>
        <transport_compression_type>none</transport_compression_type>
        <verbose_logs>false</verbose_logs>
    </grpc>
    %{ endif }
</clickhouse>
