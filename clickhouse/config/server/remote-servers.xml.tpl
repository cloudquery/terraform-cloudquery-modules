<clickhouse>
    <remote_servers replace="true">
        <${cluster_name}>
            <secret>${cluster_secret}</secret>
            <shard>
                <internal_replication>true</internal_replication>
                %{~ for replica in replica_hosts ~}
                <replica>
                    <host>${replica}</host>
                    %{ if enable_encryption }
                    <port>9440</port>
                    <secure>1</secure>
                    %{ else }
                    <port>9000</port>
                    %{ endif }
                </replica>
                %{~ endfor ~}
            </shard>
        </${cluster_name}>
    </remote_servers>
</clickhouse>
