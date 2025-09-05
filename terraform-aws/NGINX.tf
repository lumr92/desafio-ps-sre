# namespace
data "kubernetes_namespace" "default" {
  metadata {
    name = "default"
  }
}

# nginx-ingress-controller
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "default"
  version    = "4.8.3"

  # Configurações para AWS EKS
  values = [
    yamlencode({
      controller = {
        # Configurações do NGINX Controller
        replicaCount = 2
        
        # Recursos
        resources = {
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }

        # Service - LoadBalancer para AWS
        service = {
          type = "LoadBalancer"
          
          # Configurações específicas do AWS LoadBalancer
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"                    = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "tcp"
            
            # SSL Certificate (se você tiver)
            # "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = var.certificate_arn
            # "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "https"
            
            # Subnets específicas (opcional)
            # "service.beta.kubernetes.io/aws-load-balancer-subnets" = "subnet-12345,subnet-67890"
            
            # Scheme
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
          
          # Portas
          ports = {
            http = 80
            https = 443
          }
          
          targetPorts = {
            http = "http"
            https = "https"
          }
        }

        # Configurações avançadas do NGINX
        config = {
          # Performance
          "worker-processes"                = "auto"
          "max-worker-connections"          = "65536"
          
          # Logging
          "log-format-escape-json"          = "true"
          "log-format-upstream"            = jsonencode({
            time       = "$time_iso8601"
            remote_addr = "$remote_addr"
            x_forwarded_for = "$proxy_add_x_forwarded_for"
            request_id = "$req_id"
            remote_user = "$remote_user"
            bytes_sent = "$bytes_sent"
            request_time = "$request_time"
            status = "$status"
            vhost = "$host"
            request_proto = "$server_protocol"
            path = "$uri"
            request_query = "$args"
            request_length = "$request_length"
            duration = "$request_time"
            method = "$request_method"
            http_referrer = "$http_referer"
            http_user_agent = "$http_user_agent"
            upstream_addr = "$upstream_addr"
            upstream_response_time = "$upstream_response_time"
            upstream_status = "$upstream_status"
          })
          
          # Security
          "enable-real-ip"                 = "true"
          "proxy-real-ip-cidr"            = "0.0.0.0/0"
          "use-forwarded-headers"         = "true"
          
          # Performance tuning
          "keep-alive"                     = "75"
          "keep-alive-requests"           = "1000"
          "upstream-keepalive-connections" = "50"
          "upstream-keepalive-requests"   = "1000"
          "upstream-keepalive-timeout"    = "60"
        }

        # Métricas
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = false  # Habilite se usar Prometheus
          }
        }

        # Autoscaling
        autoscaling = {
          enabled = true
          minReplicas = 2
          maxReplicas = 10
          targetCPUUtilizationPercentage = 70
          targetMemoryUtilizationPercentage = 70
        }

        # Affinity para distribuir pods
        affinity = {
          podAntiAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = [
              {
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "ingress-nginx"
                    "app.kubernetes.io/instance"  = "ingress-nginx"
                    "app.kubernetes.io/component" = "controller"
                  }
                }
                topologyKey = "kubernetes.io/hostname"
              }
            ]
          }
        }
      }

      # Default backend (página 404 customizada)
      defaultBackend = {
        enabled = true
        image = {
          repository = "registry.k8s.io/defaultbackend-amd64"
          tag = "1.5"
        }
        resources = {
          limits = {
            cpu = "10m"
            memory = "20Mi"
          }
          requests = {
            cpu = "10m"
            memory = "20Mi"
          }
        }
      }
    })
  ]
}