{
  "agent": {
    "metrics_collection_interval": 1,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "append_dimensions": {
        "ImageId": "$${aws:ImageId}",
        "InstanceId": "$${aws:InstanceId}",
        "InstanceType": "$${aws:InstanceType}"
    },
    "namespace": "ClickHouseNamespace",
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "cpu": {
        "resources": [
          "*"
        ],
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_USAGE_IDLE",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_nice",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_user",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_system",
            "unit": "Percent"
          }
        ],
        "totalcpu": true,
        "metrics_collection_interval": 10
      },
      "disk": {
        "resources": [
          "/",
          "${mount_path}"
        ],
        "measurement": [
          "used_percent",
          "total",
          "used"
        ],
        "ignore_file_system_types": [
          "sysfs",
          "devtmpfs"
        ],
        "metrics_collection_interval": 60
      },
      "diskio": {
        "resources": [
          "*"
        ],
        "measurement": [
          "reads",
          "writes",
          "read_time",
          "write_time",
          "io_time"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ]
      },
      "net": {
        "resources": [
          "eth0"
        ],
        "measurement": [
          "bytes_sent",
          "bytes_recv",
          "drop_in",
          "drop_out"
        ]
      }
    }
  },
  "logs": {
    "force_flush_interval": 5,
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "${file_path}",
            "log_group_name": "${log_group}",
            "log_stream_name": "${log_name}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}