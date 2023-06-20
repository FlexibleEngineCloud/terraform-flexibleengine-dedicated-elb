# Flexible Engine Dedicated Enhanced Elastic Load Balancer Terraform Module
Flexible Engine Dedicated ELB terraform module

## TF version : 1.3.5

## Module scope 

This Terraform module Elastic Load Balancer for Flexible Engine cover :

- Listeners configuration TCP/HTTP/HTTPS (With SSL certificate, and whitelist)
- Backends/Pools configuration with members
- Monitoring of backend members


## Terraform format
```hcl
module "dedicated-elb" {

  source = "../dedicated-elb"

  loadbalancer_name  = "elb"
  vpc_id             = module.network_vpc.vpc_id
  subnet_id          = module.network_vpc.subnet_ids[0]
  security_group_ids = [module.sg.id]
  cross_vpc_backend  = true
  availability_zones = [
    "eu-west-0a",
    "eu-west-0b"
  ]

  tags = {
    Environment = "dedicated-elb module"
  }

  cert = true
  // making cert=true must either create a new certificate by putting certificate and private key.
  // Or if you have already a certificate put its certificate ID in certID variable.

  domain      = "my-domain-name.com"
  cert_name   = "my-cert-name"
  private_key = <<EOT
-----BEGIN RSA PRIVATE KEY-----
RSA PRIVATE KEY HERE
-----END RSA PRIVATE KEY-----
EOT

  certificate = <<EOT
-----BEGIN CERTIFICATE-----
CERTIFICATE HERE
-----END CERTIFICATE-----
EOT

  //Uncomment if you have already certificate existing. put its certificate ID.
  //certId = "a67adc649b8a44d6ae7b5fb0041ed7d8" 
  //if you have already put certificate and privateID to create a new certificate, this variabla will be not necessary.

  ipgroups = [
    {
      name           = "ipgroup1"
      description    = "descriisfd "
      listener_index = 0

      ips  = [
        {
          ip          = "192.168.33.2"
          description = "description 1 here"
        },
        {
          ip          = "192.168.33.1"
          description = "description 2 here"
        }
      ]
    },
    {
      name           = "ipgroup2"
      listener_index = 1

      ips = [
        {
          ip          = "192.168.33.3"
          description = "description 3 here"
        }
      ]

    }
  ]

  listeners = [
    {
      name        = "testlistener"
      port        = 8080
      protocol    = "HTTPS"
      hasCert     = true // must be true for HTTPS listener
      description = "test desc"

      http2_enable       = true
      idle_timeout       = 40
      request_timeout    = 50
      response_timeout   = 60
      tls_ciphers_policy = "tls-1-1"

      forward_eip = true

      // either "white" or "black" for whitelisting and blacklisting ip address group
      // Setting access_policy must be followed with ip_group config
      access_policy = "black"

      advanced_forwarding_enabled = true

      tags = {
        Environment = "landing-zoneee"
      }
    },
    {
      name        = "httpslistener"
      port        = 443
      protocol    = "HTTPS"
      hasCert     = true // must be true for HTTPS listener
      description = "test desc"

      // either "white" or "black" for whitelisting and blacklisting ip address group
      // Setting access_policy must be followed with ip_group config
      access_policy = "white"
    },
    {
      name        = "httplistener"
      port        = 80
      protocol    = "HTTP"
      hasCert     = false
      description = "fsdffdsfd"

      tags = {
        Environment = "landing-zoneee"
      }
    }
  ]

  pools = [{
    name           = "pool_test"
    protocol       = "HTTPS"
    lb_method      = "ROUND_ROBIN"
    listener_index = 0
    },
    {
      name           = "pool_test2"
      protocol       = "HTTPS"
      lb_method      = "ROUND_ROBIN"
      listener_index = 1
    },
    {
      name           = "pool_test3"
      protocol       = "HTTP"
      lb_method      = "ROUND_ROBIN"
      listener_index = 2
    }
  ]

  backends = [
    {
      name          = "backend1"
      port          = 5044
      address_index = 0
      pool_index    = 0
      subnet_id     = module.network_vpc.subnet_ids[0]
      weight        = 4
    },
    {
      name          = "backend2"
      port          = 5044
      address_index = 1
      pool_index    = 1
      subnet_id     = module.network_vpc.subnet_ids[0]
    }
  ]

  backends_addresses = ["192.169.1.102", "192.169.1.247"]

  monitors = [
    {
      pool_index  = 0
      protocol    = "HTTPS"
      interval    = 20
      timeout     = 10
      max_retries = 3

      url_path = "/check"
    },
    {
      pool_index  = 1
      protocol    = "HTTP"
      interval    = 20
      timeout     = 10
      max_retries = 3
      port        = 5044

      url_path = "/check"
    }
  ]
}
```

## Inputs
# Terraform Variable Reference


| Name               | Description                                     | Type         | Default   | Required |
| ------------------ | ----------------------------------------------- | ------------ | --------- | :------: |
| loadbalancer_name  | Name of the Load Balancer                           | string       | n/a       |   yes    |
| description        | The description for the load balancer            | string       | ""        |    no    |
| vpc_id             | VPC ID on which to create the load balancer      | string       | n/a       |   yes    |
| subnet_id          | Subnet ID                                        | string       | n/a       |   yes    |
| cross_vpc_backend  | Associate backend server IPs with load balancer  | bool         | n/a       |   yes    |
| loadbalancer_provider | The name of the provider (currently supports "vlb") | string  | ""        |    no    |
| security_group_ids | A list of security group IDs to apply            | list(string) | []        |    no    |
| availability_zones | A list of availability zones                     | list(string) | ["eu-west-0a", "eu-west-0b"] | no |
| tags               | Key/value pairs to associate with the load balancer | map(string) | {"Environment": ""} | no |
| cert               | Boolean to determine if certificate is added     | bool         | false     |    no    |
| cert_name          | Certificate name                                | string       | ""        |    no    |
| certId             | Certificate ID                                  | string       | null      |    no    |
| private_key        | Private key in string format                     | string       | ""        |    no    |
| certificate        | Certificate in string format                     | string       | ""        |    no    |
| domain             | Domain name                                     | string       | ""        |    no    |
| ipgroups           | List of IP Address Groups                        | list(object({name = string, description = string, listener_index = number, ips = list(object({ip = string, description = string}))})) | n/a | yes |
| listeners          | List of listeners                               | list(object({name = string, port = number, protocol = string, hasCert = bool, description = string, http2_enable = bool, idle_timeout = number, request_timeout = number, response_timeout = number, tls_ciphers_policy = string, forward_eip = bool, access_policy = string, ipgroup_index = number, server_certificate = string, ca_certificate = string, sni_certificate = list(string), advanced_forwarding_enabled = bool, tags = map(string)})) | n/a | yes |
| pools              | List of pools                                   | list(object({name = string, protocol = string, lb_method = string, listener_index = number, description = string})) | n/a | yes |
| backends           | List of backends                                | list(object({name = string, port = number, address_index = string, pool_index = number, subnet_id = string, weight = number})) | n/a | yes |
| backends_addresses | List of backend addresses                       | list(any)    | n/a       |   yes    |
| monitors           | List of monitors                                | list(object({pool_index = number, protocol = string, interval =



## Outputs

| Name        | Description                   |
| ----------- | ----------------------------- |
| id          | The Load Balancer ID           |
| listeners   | The LB listeners               |
| pools       | The LB pools                   |
| members     | The LB members                 |
| monitors    | The LB monitors                |
