# A single node with integrated storage. TLS is off: publish the port on
# 127.0.0.1 only, or mount your own configuration with TLS on /etc/openbao.
storage "raft" {
  path    = "/var/lib/openbao"
  node_id = "jerboa"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"
ui           = true
