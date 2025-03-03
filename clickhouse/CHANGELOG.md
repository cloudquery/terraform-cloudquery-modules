# Changelog

## [0.4.0](https://github.com/cloudquery/terraform-cloudquery-modules/compare/clickhouse-v0.3.0...clickhouse-v0.4.0) (2025-03-03)


### Features

* Add http/https nlb resources ([#32](https://github.com/cloudquery/terraform-cloudquery-modules/issues/32)) ([c3ccf95](https://github.com/cloudquery/terraform-cloudquery-modules/commit/c3ccf95bbe8ffdb492456ff6de00c71c9f9ccb6d))

## [0.3.0](https://github.com/cloudquery/terraform-cloudquery-modules/compare/clickhouse-v0.2.0...clickhouse-v0.3.0) (2025-02-10)


### Features

* Add outputs block to examples ([#28](https://github.com/cloudquery/terraform-cloudquery-modules/issues/28)) ([18abe10](https://github.com/cloudquery/terraform-cloudquery-modules/commit/18abe10175611c60eeb8a5cd575ade66fff6fb38))


### Bug Fixes

* Configure NLB internal/external correctly ([#31](https://github.com/cloudquery/terraform-cloudquery-modules/issues/31)) ([c6217c0](https://github.com/cloudquery/terraform-cloudquery-modules/commit/c6217c00d71275924f1deed1c33c9cca76d9694c))

## [0.2.0](https://github.com/cloudquery/terraform-cloudquery-modules/compare/clickhouse-v0.1.1...clickhouse-v0.2.0) (2025-02-07)


### Features

* add tls-ssl option to module ([#14](https://github.com/cloudquery/terraform-cloudquery-modules/issues/14)) ([db1408c](https://github.com/cloudquery/terraform-cloudquery-modules/commit/db1408cc86241cbbb3f362a35c7145d28f593bbb))


### Bug Fixes

* Remove volume type variable, handle invalid index error ([#24](https://github.com/cloudquery/terraform-cloudquery-modules/issues/24)) ([947f285](https://github.com/cloudquery/terraform-cloudquery-modules/commit/947f2854557ce7981f0cdf55882ab45ad2895e5e))
* Require the user to specify the region ([#27](https://github.com/cloudquery/terraform-cloudquery-modules/issues/27)) ([406df0b](https://github.com/cloudquery/terraform-cloudquery-modules/commit/406df0b743986359c3d09e42e6f13a08e829d0c4))
* Use `cluster_name` on kms alias ([#25](https://github.com/cloudquery/terraform-cloudquery-modules/issues/25)) ([ba4ba2f](https://github.com/cloudquery/terraform-cloudquery-modules/commit/ba4ba2fe2c7d195c7a21fecbd45b47ae15b789b0))

## [0.1.1](https://github.com/cloudquery/terraform-cloudquery-modules/compare/clickhouse-v0.1.0...clickhouse-v0.1.1) (2025-02-06)


### Bug Fixes

* Example names ([#18](https://github.com/cloudquery/terraform-cloudquery-modules/issues/18)) ([519a0e5](https://github.com/cloudquery/terraform-cloudquery-modules/commit/519a0e5d157007370fc94683852600c23f128939))
* Fix examples reference to module, add CI ([#15](https://github.com/cloudquery/terraform-cloudquery-modules/issues/15)) ([d454500](https://github.com/cloudquery/terraform-cloudquery-modules/commit/d454500d200b14a356cb3776844f2e4424ad6f5b))
* Use `cluster_name` in resources names ([010b0c7](https://github.com/cloudquery/terraform-cloudquery-modules/commit/010b0c7d56e90a6144652f12352592513d36b14b))

## 0.1.0 (2025-01-24)


### Features

* Adding NLB to allow public access to cluster ([#5](https://github.com/cloudquery/terraform-cloudquery-modules/issues/5)) ([5c05039](https://github.com/cloudquery/terraform-cloudquery-modules/commit/5c05039098bdd65294f806f7aed4dba3f0fd499f))
