ARG Version=0.0.0

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG Version
ENV Version=${Version}
WORKDIR /app/
COPY --parents ./**.props ./**.targets ./
COPY --parents ./**.sln ./**.slnx ./
COPY --parents ./**.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish \
  --no-restore \
  -c Release \
  -p:PublishDirectoryRoot=/dist


FROM mcr.microsoft.com/dotnet/runtime:10.0 AS service
USER app
WORKDIR /app
COPY --from=build --chown=app:app /dist/Cathal.Multistage.Service .
CMD [ "./Cathal.Multistage.Service" ]


FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS web
USER app
WORKDIR /app
COPY --from=build --chown=app:app /dist/Cathal.Multistage.Web .
CMD [ "./Cathal.Multistage.Web" ]
