locals {
  workspace = jsondecode(file("${path.module}/workspaces/${terraform.workspace}.json"))
}
