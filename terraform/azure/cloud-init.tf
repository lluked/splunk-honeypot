# Load cloud-init to template
data "template_file" "script" {
  template = file("../../cloud-init.yml")

  vars = {
    timezone = var.timezone,
    vmUser = var.vmUser,
    traefikUser = var.traefikUser,
    traefikPassword = var.traefikPassword,
    splunkUser = var.splunkUser,
    splunkPassword = var.splunkPassword
  }
}

# Render cloud-init config from template
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}