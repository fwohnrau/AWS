data "template_cloudinit_config" "myECSUserData"{
    gzip = false
    base64_encode = false

  part {
    content = <<EOF
    #!/bin/bash -xe
    echo ECS_CLUSTER='myECSCluster' >> /etc/ecs/ecs.config
    yum install -y aws-cfn-bootstrap
    EOF
  }
}