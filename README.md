# terraform-ci

This repository contains a small Terraform configuration and a GitHub Actions workflow used for planning and applying infrastructure changes in AWS.

**Repository:** `prathakgenpact/terraform-ci`

## Project Structure

- `main.tf` — main Terraform configuration (data sources, resources, locals).
- `provider.tf` — provider block and required provider constraints.
- `variables.tf` — input variable declarations for the configuration.
- `output.tf` — declared outputs (sensitive/public outputs).
- `.github/workflows/terraform.yml` — GitHub Actions workflow to run `terraform plan` and gated `apply`.
- `prompts.txt` — auxiliary notes / prompts used while authoring the configuration.

## Overview

The configuration reads a Secrets Manager secret, decodes it into local values, provisions an EC2 instance, and exposes selected outputs. The CI workflow runs `terraform init` and `terraform plan` on push and stores the binary plan artifact; a gated `apply` step runs in a protected `production` environment.

## Requirements

- Terraform (the workflow uses `1.6.0` — adjust locally as needed).
- An AWS account and credentials with permissions to perform the necessary actions (Secrets Manager read, EC2 create, etc.).
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for CI stored in repository or organization secrets.

## Local Usage

Initialize and run Terraform locally (PowerShell example):

```powershell
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

If you need to only preview changes without creating a plan file, run:

```powershell
terraform plan
```

## Important Variables

The configuration expects a small set of variables (see `variables.tf` for details):

- `secret_name` — Secrets Manager secret name used by the configuration.
- `ami_id` — AMI ID for the `aws_instance` resource.
- `instance_type` — EC2 instance type (for example: `t3.micro`).

Set these via `terraform.tfvars`, environment variables, or the CLI `-var` flag.

## Outputs

- Public IP of the created EC2 instance (non-sensitive).
- Decoded secret value (sensitive) — avoid printing or logging this value in untrusted contexts.

## CI/CD (GitHub Actions)

- The workflow runs `terraform init` and `terraform plan` on pushes and stores the plan artifact.
- A subsequent job downloads the plan and runs `terraform apply -auto-approve tfplan` in the `production` environment (gated by environment protection rules).
- Ensure the pipeline has the least-privilege AWS credentials required to run the plan and apply steps.

## Security Notes

- Treat Secrets Manager contents and Terraform sensitive outputs with care. Do not print sensitive outputs to logs or public channels.
- Use least-privilege IAM roles/keys for both local and CI usage.
- Protect the `production` environment in GitHub with required reviewers or approvals before `apply` runs.

## Contributing

If you'd like me to also commit this `README.md` and push it to the current branch (`demo-branch`), I can do that for you — or I can change wording/formatting first. Tell me which you prefer.

## License

This repository does not include an explicit license file. Add a `LICENSE` if you want to specify reuse terms.

## Architecture Diagram

A diagram describing the high-level architecture, CI/CD flow, and interactions between Terraform, GitHub Actions, and AWS is available in `flow-diagram.txt` in the repository root. GitHub's Markdown preview supports Mermaid diagrams; the Mermaid source is included below and in `flow-diagram.txt`.

```mermaid
flowchart LR
	Repo[Repository\n(Terraform files)]
	GA[GitHub Actions\nTerraform CI/CD]
	PlanJob[Terraform Plan Job]
	ApplyJob[Terraform Apply Job\n(environment: production)]
	TFCLI[Terraform CLI\n(init -> plan -> apply)]
	AWS[AWS Account]
	SM[AWS Secrets Manager\n(secret: var.secret_name)]
	EC2[AWS EC2\nresource: aws_instance.demo]
	Outputs[Terraform Outputs\nretrieved_secret (sensitive), public_ip]

	Repo -->|push to main| GA
	GA --> PlanJob
	PlanJob -->|checkout + setup aws creds| TFCLI
	TFCLI -->|terraform init & plan| AWS
	TFCLI -->|uploads tfplan artifact| GA
	GA --> ApplyJob
	ApplyJob -->|manual approval| TFCLI
	TFCLI -->|apply tfplan| AWS
	AWS --> SM
	AWS --> EC2
	SM -->|secret_string| TFCLI
	TFCLI -->|jsondecode -> local.secret_data| Outputs
	EC2 --> Outputs
```
