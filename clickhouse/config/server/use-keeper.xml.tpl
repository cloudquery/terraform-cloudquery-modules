<clickhouse>
    <zookeeper>
        %{~ for keeper in keeper_nodes ~}
        <!-- where are the ZK nodes -->
        <node>
            <host>${keeper}</host>
            <port>9181</port>
        </node>
        %{~ endfor ~}
    </zookeeper>
</clickhouse>