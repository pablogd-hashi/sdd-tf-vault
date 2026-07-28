package test

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func vaultAvailable() bool {
	addr := os.Getenv("VAULT_ADDR")
	if addr == "" {
		addr = "http://127.0.0.1:8200"
	}
	cmd := exec.Command("curl", "-sf", addr+"/v1/sys/health")
	return cmd.Run() == nil
}

func TestVaultServiceOnboardModule(t *testing.T) {
	if os.Getenv("SKIP_VAULT_TESTS") == "true" {
		t.Skip("SKIP_VAULT_TESTS=true")
	}
	if !vaultAvailable() {
		t.Skip("Vault not reachable at VAULT_ADDR; run 'make bootstrap && make platform-apply' first")
	}

	vaultAddr := os.Getenv("VAULT_ADDR")
	if vaultAddr == "" {
		vaultAddr = "http://127.0.0.1:8200"
	}
	vaultToken := os.Getenv("VAULT_TOKEN")
	if vaultToken == "" {
		vaultToken = "root"
	}

	uniqueSuffix := fmt.Sprintf("%d", time.Now().Unix())
	serviceName := "test-svc-" + uniqueSuffix
	team := "testteam"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/modules/vault-service-onboard/examples/minimal",
		Vars: map[string]interface{}{
			"service_name":         serviceName,
			"team":                 team,
			"namespace":            "default",
			"service_account":      "test-sa",
			"secret_paths":         []string{"config"},
			"kubernetes_auth_path": "kubernetes",
			"kv_mount_path":        "secret",
			"vault_addr":           vaultAddr,
			"vault_token":          vaultToken,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	policyName := terraform.Output(t, terraformOptions, "policy_name")
	roleName := terraform.Output(t, terraformOptions, "role_name")

	assert.Equal(t, team+"-"+serviceName, policyName)
	assert.Equal(t, team+"-"+serviceName, roleName)

	// Verify policy exists via vault CLI
	if _, err := exec.LookPath("vault"); err == nil {
		cmd := exec.Command("vault", "policy", "read", policyName)
		cmd.Env = append(os.Environ(), "VAULT_ADDR="+vaultAddr, "VAULT_TOKEN="+vaultToken)
		out, err := cmd.CombinedOutput()
		require.NoError(t, err, string(out))
		assert.True(t, strings.Contains(string(out), "teams/"+team+"/"+serviceName))
	}
}
