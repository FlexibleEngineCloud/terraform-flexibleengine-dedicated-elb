// Dedicated ELB
module "dedicated-elb" {

  source = "../dedicated-elb"

  loadbalancer_name  = "elb"
  vpc_id             = module.network_vpc.vpc_id
  subnet_id          = module.network_vpc.subnet_ids[0]
  security_group_ids = [module.sg_dmz.id]
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