<clickhouse>
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
</clickhouse>
