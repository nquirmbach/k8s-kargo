include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Prod environment - deploy all units in dependency order
# Terragrunt will automatically resolve dependencies and deploy in correct order:
# 1. networking (no dependencies)
# 2. cluster (depends on networking)
