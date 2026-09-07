# dotnet-docker-multistage

A sample .NET 10 repository demonstrating multi-stage container builds for different application components (`service` and `web`) from a single `Dockerfile`.

---

## Multi-Target Architecture

The project contains multiple applications within a single solution:

- **`service`**: Background worker/service application (`Cathal.Multistage.Service`) built on `mcr.microsoft.com/dotnet/runtime:10.0-alpine`.
- **`web`**: ASP.NET Core Web API/application (`Cathal.Multistage.Web`) built on `mcr.microsoft.com/dotnet/aspnet:10.0-alpine`.

A shared `build` stage compiles all projects in the solution and outputs published artifacts to `/dist/`. The final container image is selected using target stages in the [Dockerfile](./Dockerfile).

---

## Building Targets

You can build specific target images using either **Docker** or **Podman**.

### Available Targets

- `--target service`: Builds the `Cathal.Multistage.Service` container image.
- `--target web`: Builds the `Cathal.Multistage.Web` container image.

---

### Building

#### Build `service` target

```bash
docker build --target service -t cathal-multistage-service:latest .
```

or

```bash
podman build --target service -t cathal-multistage-service:latest .
```

#### Build `web` target

```bash
docker build --target web -t cathal-multistage-web:latest .
```

or

```bash
podman build --target web -t cathal-multistage-web:latest .
```

---

#### Multi-Architecture Build (AMD64 & ARM64)

Docker's default `docker` driver uses a classic storage driver which does not support multi-platform manifest lists locally without pushing to a registry. This leaves two options:

1. Build an OCI tarball
1. Use the containerd image store instead of the default

Neither of these options are particularly clean for demonstration purposes.

```bash
# (re)Create and use a multi-architecture builder instance
docker buildx create --name multiarch-builder --driver docker-container --use 2>/dev/null || docker buildx use multiarch-builder

# Build multi-architecture image
docker buildx build --platform linux/amd64,linux/arm64 --target service -t cathal-multistage-service:latest .
```

Podman supports local manifest lists within it's image store. This requires creating a manifest first.

```bash
# (re)Create manifest
podman manifest rm cathal-multistage-service:latest 2>/dev/null || true
podman manifest create cathal-multistage-service:latest

# Build directly into manifest
podman build --platform linux/amd64,linux/arm64 --manifest cathal-multistage-service:latest --target service .
```
