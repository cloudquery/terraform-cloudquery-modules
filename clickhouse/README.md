# CloudQuery ClickHouse Terraform Module

## Overview

Installs clickhouse-server and clickhouse-keeper to provide a ClickHouse cluster with replication enabled. Access is via a public-facing NLB. Currently only a single shard is used.

## Architecture

Architecture for a self-hosted clickhouse install supporting [replication](https://clickhouse.com/docs/en/architecture/replication).

![ClickHouse Architecutre](./docs/clickhouse_architecture.png)

## Testing

The following can be used to insert some data for testing purposes. Note the use of `on cluster <cluster-name>` in the database and table creation steps. Clickhouse Cloud abstracts this away from users.

- Create a database

```sql
create database db1 on cluster clickhouse_cluster;
```

- Create a table

```sql
CREATE TABLE db1.table1 ON CLUSTER clickhouse_cluster
(  
`id` UInt64,  
`column1` String  
)  
ENGINE = ReplicatedMergeTree  
ORDER BY id
```

- Insert some data

```sql
INSERT INTO db1.table1 (id, column1) VALUES (1, 'abc');
```

At this stage the data should be present on all nodes of the cluster given that is it configured as a single shard + n replica cluster.

## TODO

- [ ] Add CI/CD for validating and documenting Terraform
- [ ] Add a default user with a password
- [ ] Add certificates to the ClickHouse server
- [ ] Add support for [sharding](https://clickhouse.com/docs/en/architecture/horizontal-scaling)
