
## Terraform Provisioning

### Chef Provisioner deprecated

This provisioner has been deprecated as of Terraform 0.13.4 and will be removed in a future version of Terraform. For most common situations there are better alternatives to using provisioners.

```
resource "aws_instance" "web" {
  # ...

  provisioner "chef" {
    attributes_json = <<EOF
      {
        "key": "value",
        "app": {
          "cluster1": {
            "nodes": [
              "webserver1",
              "webserver2"
            ]
          }
        }
      }
    EOF

    environment     = "_default"
    client_options  = ["chef_license 'accept'"]
    run_list        = ["cookbook::recipe"]
    node_name       = "webserver1"
    secret_key      = "${file("../encrypted_data_bag_secret")}"
    server_url      = "https://chef.company.com/organizations/org1"
    recreate_client = true
    user_name       = "bork"
    user_key        = "${file("../bork.pem")}"
    version         = "15.10.13"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_peer"
  }
}
```

### Provisioners are a Last Resort
 * Terraform cannot model the actions of provisioners as part of a plan because
 they can in principle take any action.
 * Secondly, successful use of provisioners requires coordinating many more
 details than Terraform usage usually requires: direct network access to your
 servers, issuing Terraform credentials to log in, making sure that all of
 the necessary external software is installed, etc.

Alternatives:
 * Passing data into virtual machines and other compute resources, e.g. AWS EC2 `user_data`
   or `user_data_base64`. `user_data` understands only two user data formats – shell script and cloud-config directives. [cloud-init](https://cloudinit.readthedocs.io/en/latest/)
   can be used to automatically process in various ways data passed via `user_data`.
 * Instead of configuration management software use [HashiCorp Packer](https://www.packer.io/)
   to build custom image

Allowed provisioners are the built-in `file`, `local-exec`, and `remote-exec`.
```
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${aws_instance.web.private_ip} >> private_ips.txt"
  }
}
```

### Bootstrapping Linux EC2 node with User Data
The following repository demonstrates how Chef Infra Client can be installed on node by using an unattended bootstrap.
Script `scripts/user_data.tmpl` will install on instance `chef-client` and register (bootstrap) it with private chef server.

If you want run terraform script, then do the following:

1. Use AWS key pair name with known private key (line 51 in instances/main.tf)

2. Reregister `your-validator` client validator key. In your `chef-repo` directory run
  ```
   knife client reregister your-validator -f ./your-validator.pem
  ```

3. In `instance` folder copy `terraform.tfvars.sample` to `terraform.tfvars`. Then edit valiable `node_name`, `chef_server_url` attributes and copy content of file `./your-validator.pem` to `validator_private_key`. Also, edit variable definition of `validator_name` and set to your validation client name.   

4. Go to `instance` directory and execute these commands:
  ```
  terraform init && terraform apply
  ```

5. Verify your instance
  ```
  ssh ubuntu@$(echo "aws_instance.node.private_ip" | terraform console) -i ~/.ssh/you-private-key.pem
  ```
### Useful links
1. [Bootstrapping with User Data](https://docs.chef.io/install_bootstrap/#bootstrapping-with-user-data)
