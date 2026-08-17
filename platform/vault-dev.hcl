# Extra telemetry for Vault -dev so Prometheus can scrape /v1/sys/metrics.
# Combined with: vault server -dev -config=platform/vault-dev.hcl

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}
