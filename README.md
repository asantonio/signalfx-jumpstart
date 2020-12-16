# SignalFx Jumpstart
**Requires Terraform (minimum) v0.13**

## Clone this repository:

`git clone https://github.com/signalfx/signalfx-jumpstart.git`

## Initialise Terraform

```
$ terraform init --upgrade
```

## Create a workspace

```
$ terraform workspace new my_workspace
```

## Review the execution plan

```
$ terraform plan -var="access_token=abc123" -var="realm=eu0"
```

Where `access_token` is the SignalFx Access Token and `realm` is either `eu0`, `us0`, `us1` or `us2`

## Apply the changes

```
$ terraform apply -var="access_token=abc123" -var="realm=eu0"
```

## Destroy everything!

If you created a workspace you will first need to ensure you are in the correct workspace e.g.

```
$ terraform workspace select my_workspace
```

```
$ terraform destroy -var="access_token=abc123" -var="realm=eu0"
```

# Deploying a module

```
terraform apply -var="access_token=abc123" -var="realm=eu0" -target=module.aws
terraform apply -var="access_token=abc123" -var="realm=eu0" -target=module.dashboards
terraform apply -var="access_token=abc123" -var="realm=eu0" -target=module.gcp
```
