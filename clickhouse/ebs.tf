resource "aws_ebs_volume" "clickhouse" {
  for_each          = local.cluster_nodes
  availability_zone = module.vpc.private_subnet_objects[each.value.subnet_index].availability_zone
  size              = var.clickhouse_volume_size
  type              = var.clickhouse_volume_type
  throughput        = var.clickhouse_volume_type == "gp3" ? 125 : null
  iops              = contains(["io1", "io2", "gp3"], var.clickhouse_volume_type) ? 3000 : null
  tags              = var.tags
}

resource "aws_volume_attachment" "clickhouse" {
  for_each    = local.cluster_nodes
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.clickhouse[each.key].id
  instance_id = module.clickhouse_cluster[each.key].id
}

resource "aws_ebs_volume" "keeper" {
  for_each          = local.keeper_nodes
  availability_zone = module.vpc.private_subnet_objects[each.value.subnet_index].availability_zone
  size              = var.keeper_volume_size
  type              = var.keeper_volume_type
  throughput        = var.keeper_volume_type == "gp3" ? 125 : null
  iops              = contains(["io1", "io2", "gp3"], var.keeper_volume_type) ? 3000 : null
  tags              = var.tags
}

resource "aws_volume_attachment" "keeper" {
  for_each    = local.keeper_nodes
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.keeper[each.key].id
  instance_id = module.clickhouse_keeper[each.key].id
}
