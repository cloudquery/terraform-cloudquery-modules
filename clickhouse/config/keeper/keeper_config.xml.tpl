<clickhouse>
    <keeper_server>
        %{ if enable_encryption }
        <tcp_port_secure>${keeper_port_secure}</tcp_port_secure>
        %{ else }
        <tcp_port>${keeper_port}</tcp_port>
        %{ endif }
        <server_id>${server_id}</server_id>

        <log_storage_path>/var/lib/clickhouse/coordination/log</log_storage_path>
        <snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>

        <coordination_settings>
            <operation_timeout_ms>10000</operation_timeout_ms>
            <session_timeout_ms>30000</session_timeout_ms>
            <raft_logs_level>information</raft_logs_level>
        </coordination_settings>

        <raft_configuration>
            %{ if enable_encryption }
            <secure>true</secure>
            %{ endif }
            %{~ for keeper in keeper_nodes ~}
            <server>
                <id>${keeper.id}</id>
                <hostname>${keeper.host}</hostname>
                <port>${keeper_raft_port}</port>
            </server>
            %{~ endfor ~}
        </raft_configuration>
    </keeper_server>

    %{ if enable_encryption }
    <openSSL>
        <server>
            <certificateFile>/etc/clickhouse-keeper/server.crt</certificateFile>
            <privateKeyFile>/etc/clickhouse-keeper/server.key</privateKeyFile>
            <verificationMode>relaxed</verificationMode>
            <caConfig>/etc/clickhouse-keeper/ca.crt</caConfig>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
        </server>
        <client>
            <loadDefaultCAFile>false</loadDefaultCAFile>
            <caConfig>/etc/clickhouse-keeper/ca.crt</caConfig>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
            <verificationMode>relaxed</verificationMode>
            <invalidCertificateHandler>
                <name>RejectCertificateHandler</name>
            </invalidCertificateHandler>
        </client>
    </openSSL>
    %{ endif }
</clickhouse>
