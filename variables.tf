variable "cluster_sla" {
  description = "Cluster SLA"
  type        = string
  default     = "none"
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "~/.kube/config"
}

variable "flux_git_repo" {
  description = "GitRepository URL."
  type        = string
  default     = ""
}

variable "flux_wait" {
  description = "Wait for all manifests to apply"
  type        = bool
  default     = true
}

variable "flux_version" {
  description = "Flux version to install"
  type        = string
  default     = "v0.15.3"
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
}

variable "customer_name" {
  description = "Customer name (Informative only)"
  type        = string
}

variable "cronitor_enabled" {
  description = "Creates and enables Cronitor monitor."
  type        = bool
  default     = false
}

variable "cronitor_pagerduty_key" {
  description = "Cronitor PagerDuty key"
  type        = string
  default     = ""
}

variable "cronitor_notification_list" {
  description = "Cronitor Notification List to send alerts"
  type        = list(string)
  default     = []
}

variable "opsgenie_enabled" {
  description = "Creates and enables Opsgenie integration."
  type        = bool
  default     = false
}

variable "opsgenie_team_name" {
  description = "Opsgenie Owner team name of the integration."
  type        = string
  default     = "Operations"
}

variable "manifests_template_vars" {
  description = "Template vars for use by cluster manifests"
  type        = any
  default     = {}
}

variable "teleport_auth_token" {
  description = "Teleport Agent auth token"
  type        = string
  default     = ""
}

variable "use_kubeconfig" {
  description = "Should kubernetes/kubectl providers use local kubeconfig or credentials from cloud module"
  type        = bool
  default     = false
}

variable "pre_create" {
  description = "Scripts to execute before cluster is created."
  type        = list(string)
  default     = []
}

variable "post_create" {
  description = "Scripts to execute after cluster is created."
  type        = list(string)
  default     = []
}
