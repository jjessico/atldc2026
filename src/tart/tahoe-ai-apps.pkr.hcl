packer {
  required_plugins {
    tart = {
      version = ">= 0.5.3"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "tahoe-ai-apps"
}

source "tart-cli" "ai_apps" {
  vm_base_name = "ghcr.io/cirruslabs/macos-tahoe-base:latest"
  vm_name      = var.vm_name
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 50
  headless     = true
  ssh_username = "admin"
  ssh_password = "admin"
  ssh_timeout  = "120s"
}

build {
  sources = ["source.tart-cli.ai_apps"]

  provisioner "shell" {
    inline = [
      "eval \"$(/opt/homebrew/bin/brew shellenv)\"",
      "brew install --cask claude chatgpt",
      "ls -d /Applications/Claude.app /Applications/ChatGPT.app"
    ]
  }
}
