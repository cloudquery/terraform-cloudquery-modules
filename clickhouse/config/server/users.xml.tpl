<clickhouse>
    <profiles>
        <default>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </default>
    </profiles>

    <users>
        <default>
            <password_sha256_hex>${default_password_hash}</password_sha256_hex>
            <networks>
                %{~ for ip in default_allowed_ips ~}
                <ip>${ip}</ip>
                %{~ endfor ~}
            </networks>
            <profile>default</profile>
            <quota>default</quota>
            <access_management>0</access_management>
        </default>

        <admin>
            <password_sha256_hex>${admin_password_hash}</password_sha256_hex>
            <networks>
                %{~ for ip in admin_allowed_ips ~}
                <ip>${ip}</ip>
                %{~ endfor ~}
            </networks>
            <profile>default</profile>
            <quota>default</quota>
            <access_management>1</access_management>
        </admin>
    </users>

    <quotas>
        <default>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </default>
    </quotas>
</clickhouse>
