<clickhouse>
    <zookeeper>
        %{~ for keeper in keeper_nodes ~}
        <node>
            <host>${keeper}</host>
            %{ if enable_encryption }
            <port>${keeper_port_secure}</port>
            <secure>1</secure>
            %{ else }
            <port>${keeper_port}</port>
            %{ endif }
        </node>
        %{~ endfor ~}
    </zookeeper>
</clickhouse>
