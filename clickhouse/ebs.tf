resource "aws_ebs_volume" "clickhouse" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  size              = var.clickhouse_volume_size
  type              = var.clickhouse_volume_type
}

resource "aws_volume_attachment" "clickhouse" {
  count       = length(local.azs)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.clickhouse[count.index].id
  instance_id = module.clickhouse_cluster[count.index].id
}

resource "aws_ebs_volume" "keeper" {
  count             = length(local.azs)
  availability_zone = local.azs[count.index]
  size              = var.keeper_volume_size
  type              = var.keeper_volume_type
}

resource "aws_volume_attachment" "keeper" {
  count       = length(local.azs)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.keeper[count.index].id
  instance_id = module.clickhouse_keeper[count.index].id
}
