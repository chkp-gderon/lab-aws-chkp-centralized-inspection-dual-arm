# aws-lz-chkp-centralized-inspection-dual-arm

AWS Centralized Inspection Landing Zone with Check Point Cloud Firewalls in a dual-arm deployment

This repository contains Terraform configurations and modules to deploy a centralized inspection landing zone using Check Point appliances in a dual-arm (inbound/outbound) design on AWS. It supports autoscaling groups, GWLB integration, and several reusable modules to customize deployments for labs and production-like environments.

## Repository layout

- `*.tf` — top-level Terraform configuration for a complete deployment (entrypoint)
- `modules/` — reusable modules used by the root configuration (ASGs, GWLB, VPC, IAM, etc.)
- `keys/` — sample keys used for lab instances
- `tfplan`, `tfplan.json`, `terraform.tfstate*` — plan/state artifacts (not tracked by best practice)

See the `modules/` directory for module-level README files and usage notes.

## Architecture overview

The deployment provisions:
- A VPC with public/private subnets across AZs
- Auto Scaling Groups for Check Point gateway instances (dual-arm or GWLB variants)
- IAM roles and policies scoped for the appliances and autoscale lifecycle
- Optional integration with Gateway Load Balancer (GWLB) and traffic mirroring
- CloudWatch logs/metrics and optional centralized management

Refer to `modules/*/README.md` for module-specific architecture diagrams and options.

## Prerequisites

- Terraform >= the version defined in `versions.tf` (see [versions.tf](versions.tf))
- AWS credentials configured with sufficient permissions to create networking, EC2, IAM, and autoscaling resources. Example using AWS SSO profile:

```bash
aws configure sso --profile terraform
export AWS_PROFILE=terraform
```

- Optional: `jq` for parsing outputs when using `tfplan.json` or automation.

## Quick start

1. Initialize Terraform and download provider plugins:

```bash
terraform init
```

2. Validate the configuration and view plan:

```bash
terraform validate
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

3. Apply the plan (use `-auto-approve` for automation):

```bash
terraform apply tfplan
```

4. Destroy resources when finished:

```bash
terraform destroy -auto-approve
```

Notes:
- Use `terraform.tfvars` or `-var-file=terraform.tfvars` to pass environment-specific variables.
- The repo includes `terraform.tfvars.example` as a template for common settings.

## Configuration and variables

- Global variables are declared in `variables.tf` and module-level variables in each module's `variables.tf`.
- Sensitive values such as admin passwords or license keys should be provided via secure mechanisms (SSM Parameter Store, Vault) rather than checked into the repo.

Files to review before running:
- [variables.tf](variables.tf)
- [providers.tf](providers.tf)
- [terraform.tfvars.example](terraform.tfvars.example)

## Modules

This repo contains many modules under `modules/`. Common ones include:
- `autoscale/` — generic autoscaling for appliances
- `autoscale_gwlb/` and `gwlb*/` — GWLB-specific autoscale and integration
- `cluster/`, `cluster_master/` — cluster configurations and master images
- `vpc/`, `load_balancer/`, `elastic_ip/`, `instance_type/` — infra primitives

Each module typically contains its own `README.md` with usage notes and input/output descriptions.

## State management

- By default this repository may use local state files. For team or multi-runner usage, configure remote state backend (S3 + DynamoDB) in `backend` configuration.
- Keep `terraform.tfstate` and sensitive plan outputs out of source control.

## Testing & Validation

- Use `terraform validate` and `terraform plan` for syntactic and semantic checks.
- For module-level unit tests, consider using `terratest` or similar frameworks.

## Troubleshooting

- If `terraform apply` fails, inspect the error message and check AWS console for partially created resources.
- Common issues: IAM permission errors, quota limits, missing AMI IDs. Check `modules/amis` for AMI references.

## Contributing

Contributions are welcome. Please open issues or PRs with clear descriptions. Follow the repository style and test any config changes against a disposable environment.

## License

See the repository root for license information or add one if needed.

## Contact / Maintainers

For questions about this deployment, consult the team or repository owner.

