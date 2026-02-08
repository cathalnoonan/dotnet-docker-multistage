ARG Version=0.0.0
ARG TARGETARCH

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG Version
ENV Version=${Version}
WORKDIR /app/
COPY --parents ./**.props .
COPY --parents ./**.targets .
COPY --parents ./*.sln .
COPY --parents ./*.slnx .
COPY --parents ./src/**/*.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish \
  --no-restore \
  -c Release \
  -p:PublishDirectoryRoot=/dist


FROM mcr.microsoft.com/dotnet/runtime:10.0 AS service
USER app
WORKDIR /app
COPY --from=build /dist/Cathal.Multistage.Service .
CMD [ "/app/Cathal.Multistage.Service" ]


FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS web
USER app
WORKDIR /app
COPY --from=build /dist/Cathal.Multistage.Web /app/
CMD [ "/app/Cathal.Multistage.Web" ]
