<clickhouse>
    <remote_servers replace="true">
        <${cluster_name}>
            <secret>${cluster_secret}</secret>
            <shard>
                <internal_replication>true</internal_replication>
                %{~for replica in replica_hosts~}
                <replica>
                    <host>${replica}</host>
                    <port>9000</port>
                </replica>
                %{~ endfor ~}
            </shard>
        </${cluster_name}>
    </remote_servers>
</clickhouse>