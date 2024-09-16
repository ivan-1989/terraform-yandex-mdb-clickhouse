output "ch_conn" {
#  sensitive = true
  description = <<EOF
    How connect to ClickHouse cluster?

    1. Install certificate

      mkdir -p /usr/local/share/ca-certificates/Yandex/ && \\
      wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt && \\
      chmod 0655 /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt

    2. Upload config.

      mkdir --parents ~/.clickhouse-client && \\
      wget "https://storage.yandexcloud.net/doc-files/clickhouse-client.conf.example" -O ~/.clickhouse-client/config.xml

    3. Run connection string from the output value, for example
    EOF
  value = <<EOT
clickhouse-client --host c-${module.clickhouse.c01.cluster_id}.rw.mdb.yandexcloud.net \
                  --secure \
                  --user admin\
                  --port 9440 \
                  --ask-password 
    EOT
}