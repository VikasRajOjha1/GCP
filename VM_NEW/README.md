# Low-budget Google Cloud VM: Terraform modules + GitHub Actions

This configuration is split into reusable modules:

- `modules/network`: custom VPC, subnet, and an optional firewall rule allowing SSH through IAP only.
- `modules/compute_vm`: Ubuntu 24.04 VM and its dedicated service account.
- Root files: providers, variables, module wiring, outputs, and the GCS remote-state backend.

The defaults target low usage: `e2-micro`, 10 GiB `pd-standard` boot disk, no external IP, no Cloud NAT, and IAP-only SSH. The VM has OS Login enabled. With no external IP/NAT, it does not have general outbound internet access; Private Google Access permits access to supported Google APIs.

**Free tier is not a guarantee of a $0 bill.** Google Cloud eligibility depends on billing-account status, region, monthly usage, and current Google terms. The commonly documented Compute Engine free allowance is one non-preemptible `e2-micro` instance-month in eligible US regions (`us-central1`, `us-east1`, or `us-west1`), up to 30 GiB-month of standard persistent disk, and limited outbound transfer. This stack restricts the region to those regions and defaults to 10 GiB, but the VM, state bucket, logging, network traffic, or account usage can still incur charges. Check the current Google Cloud Free Program and pricing before applying; configure budget alerts. Terraform intentionally keeps public IP and NAT disabled by default because they can add charges.

## Google Cloud setup (one time)

Choose a project with billing enabled. The setup operator needs permission to enable APIs, create service accounts and IAM bindings, create a GCS bucket, and configure Workload Identity Federation. The state bucket is a separate resource and may incur small storage/operation charges.

```sh
export PROJECT_ID="your-google-cloud-project-id"
export REGION="us-central1"
export TF_SA_NAME="terraform-github"
export STATE_BUCKET="${PROJECT_ID}-terraform-state"

gcloud config set project "$PROJECT_ID"
gcloud services enable compute.googleapis.com iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com --project="$PROJECT_ID"

gcloud iam service-accounts create "$TF_SA_NAME" \
  --display-name="GitHub Actions Terraform deployment"

gcloud storage buckets create "gs://${STATE_BUCKET}" \
  --project="$PROJECT_ID" --location="$REGION" \
  --uniform-bucket-level-access
gcloud storage buckets update "gs://${STATE_BUCKET}" --versioning
```

Grant the deployment identity the required permissions. For a production setup, further scope IAM permissions to the individual resources where practical.

```sh
export TF_SA="${TF_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

for ROLE in roles/compute.admin roles/iam.serviceAccountAdmin roles/iam.serviceAccountUser roles/serviceusage.serviceUsageConsumer; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${TF_SA}" --role="$ROLE"
done

gcloud storage buckets add-iam-policy-binding "gs://${STATE_BUCKET}" \
  --member="serviceAccount:${TF_SA}" --role="roles/storage.objectAdmin"
```

## GitHub OIDC / Workload Identity Federation

This avoids storing a long-lived service-account key in GitHub. Set `OWNER` to the GitHub account/organization and `REPO` to the repository name. The provider condition restricts federation to this repository's `main` branch; pull requests receive no Google Cloud credentials.

```sh
export OWNER="your-github-owner"
export REPO="your-repository-name"
export POOL_ID="github-actions"
export PROVIDER_ID="github"
export PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"

gcloud iam workload-identity-pools create "$POOL_ID" \
  --project="$PROJECT_ID" --location="global" --display-name="GitHub Actions"

gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
  --project="$PROJECT_ID" --location="global" --workload-identity-pool="$POOL_ID" \
  --display-name="GitHub Actions provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition="assertion.repository=='${OWNER}/${REPO}' && assertion.ref=='refs/heads/main'"

gcloud iam service-accounts add-iam-policy-binding "$TF_SA" \
  --project="$PROJECT_ID" --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository/${OWNER}/${REPO}"
```

In **Repository Settings → Secrets and variables → Actions → Variables**, add:

| Variable | Value |
| --- | --- |
| `GCP_PROJECT_ID` | Your Google Cloud project ID |
| `GCP_TERRAFORM_SERVICE_ACCOUNT` | The full email, for example `terraform-github@PROJECT_ID.iam.gserviceaccount.com` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID` with actual values |
| `TF_BACKEND_BUCKET` | The GCS bucket name, without `gs://` |

For a human approval gate before production changes, create a GitHub `production` environment with required reviewers and add `environment: production` to the workflow job.

## Run and connect

Push to `main` or manually run **Actions → Terraform - Google Cloud VM → Run workflow** using `main`. Pull requests perform formatting and Terraform validation without cloud credentials; a trusted `main` run uses the remote GCS state, plans, and applies.

For IAP access, grant your own Google user the following roles (not the Terraform service account):

- `roles/iap.tunnelResourceAccessor` to open the IAP tunnel.
- `roles/compute.osLogin` to log in, or `roles/compute.osAdminLogin` if sudo access is needed.

Then connect with `gcloud compute ssh tutorial-vm-instance --zone=us-central1-a --project=PROJECT_ID --tunnel-through-iap`. The VM has no public IP by default. If you set `assign_public_ip = true`, an external IPv4 address may generate additional charges.

The root outputs provide the VM name, zone, IP addresses (external IP is null by default), and VM service-account email. Change defaults in `variables.tf` or provide an ignored local `terraform.tfvars` based on `terraform.tfvars.example`. Keep the zone in the selected region, the machine type at `e2-micro`, and the disk at or below 30 GiB to target the published free allowance.

## Destroy

Run `terraform destroy` from this directory with Google credentials configured and the same GCS backend settings, or create a separately protected destroy workflow. Do not delete the state bucket before destroying the managed resources and retaining any state history you need.