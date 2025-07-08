terraform {
  required_providers {
    docker = {
        source = "kreuzwerker/docker"
        version = "3.0.2"
    }
  }
}

provider "docker" {}

resource "docker_image" "postgres" {
  name = "postgres:latest"

}

resource "docker_image" "redis" {
  name = "redis:latest"
}

resource "docker_image" "desafio-sre" {
  name = "desafio-sre"
  
  build {
    context     = "."
    tag         = ["app-desafio-sre:latest"]
    build_arg   = {
        foo : "app"
    }
  }
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres"
  
  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=senhafacil",
    "POSTGRES_DB=postgres"
  ]

  ports {
    internal = 5432
    external = 5433
  }

  volumes {
    container_path = "postgres:/var/lib/postgres/data"
  }

  networks_advanced {
    name = docker_network.app-network.name
  }
}

resource "docker_container" "redis" {
  image = docker_image.redis.image_id
  name  = "redis"

  ports {
    internal = 6379
    external = 6378
  }

  volumes {
    container_path = "redis:/var/lib/redis/data"
  }

  networks_advanced {
    name = docker_network.app-network.name
  }
}

resource "docker_container" "desafio-sre" {
  image = docker_image.desafio-sre.image_id
  name = "desafio-sre"

  env = [
    "REDIS_HOST=redis",
    "REDIS_PORT=6379",
    "POSTGRES_HOST=postgres",
    "POSTGRES_PORT=5432",
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=senhafacil",
    "POSTGRES_DB=postgres"
  ]

  depends_on = [ docker_container.redis, docker_container.postgres ]

  ports {
    internal = 5000
    external = 5000
  }

  ports {
    internal = 9999
    external = 9999
  }

  volumes {
    host_path = "/home/elvenworks16/elven/estudos/desafio-sre/app/"
    container_path = "/app"
  }

  networks_advanced {
    name = docker_network.app-network.name
  }

}

resource "docker_volume" "postgres" {
  name = "postgres"
}

resource "docker_volume" "redis" {
  name = "redis"
}

resource "docker_network" "app-network" {
  name = "app-network"
  driver = "bridge"
}