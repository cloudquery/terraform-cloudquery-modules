# config/server/remote-servers.xml.tpl
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
                    %{ if enable_encryption }
                    <port>9440</port>
                    <secure>1</secure>
                    %{ else }
                    <port>9000</port>
                    %{ endif }
                </replica>
                %{~ endfor ~}
            </shard>
            %{~ endfor ~}
        </${cluster_name}>
    </remote_servers>
</clickhouse>
