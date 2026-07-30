## Platform Engineering — Vault onboarding complete

**Ticket:** PE-XXX
**Ticket provider:** jira
**PR:** (link)
**Validation:** PASS

### Summary

Vault service onboarding Terraform has been validated and reviewed. Pull request ready for merge.

### Resources created

- Policy: `{team}-{service_name}`
- K8s auth role: `{team}-{service_name}`
- Secret paths: (list)

### Next steps for requester

1. Review and merge the PR
2. Application team can mount secrets via Vault Agent or direct K8s auth
