variable "name" {
  description = "Prefixe des ressources, par exemple novasphere-dev-web"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,28}$", var.name))
    error_message = "name : 3 a 28 caracteres, minuscules, chiffres et tirets."
  }
}

variable "vpc_id" {
  description = "VPC dans lequel creer le Security Group des instances"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets ou l'ASG place les instances (au moins deux zones)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids : au moins deux subnets, pour deux zones de disponibilite."
  }
}

variable "alb_security_group_id" {
  description = "Security Group de l ALB, seule source autorisee vers les instances"
  type        = string
}

variable "target_group_arns" {
  description = "Target groups dans lesquels l'ASG enregistre les instances"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI des instances"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance (le Learner Lab accepte nano a large)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("\\.(nano|micro|small|medium|large)$", var.instance_type))
    error_message = "instance_type : taille nano, micro, small, medium ou large uniquement."
  }
}

variable "user_data" {
  description = "Script d'amorcage deja rendu (texte brut, encode en base64 par le module)"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Profil IAM des instances (LabInstanceProfile dans le Learner Lab), null pour aucun"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Nombre minimal d'instances"
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "min_size : au moins 2 instances (cahier des charges)."
  }
}

variable "max_size" {
  description = "Nombre maximal d'instances"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Nombre d'instances souhaite"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags supplementaires"
  type        = map(string)
  default     = {}
}
