<clickhouse>
    <zookeeper>
        %{~ for keeper in keeper_nodes ~}
        <node>
            <host>${keeper}</host>
            %{ if enable_encryption }
            <port>9281</port>
            <secure>1</secure>
            %{ else }
            <port>9181</port>
            %{ endif }
        </node>
        %{~ endfor ~}
    </zookeeper>
</clickhouse>
