<clickhouse>
    <remote_servers replace="true">
        <${cluster_name}>
            <secret>${cluster_secret}</secret>
            %{~ for shard_index, shard in shard_hosts ~}
            <shard>
                <internal_replication>true</internal_replication>
                <weight>${shard.weight}</weight>
                %{~ for replica in shard.replicas ~}
                <replica>
                    <host>${replica.host}</host>
                    <port>9000</port>
                </replica>
                %{~ endfor ~}
            </shard>
            %{~ endfor ~}
        </${cluster_name}>
    </remote_servers>
</clickhouse>
