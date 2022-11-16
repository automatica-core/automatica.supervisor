FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /app

ARG VERSION

#install automatica-cli
RUN dotnet tool install --global automatica-cli
ENV PATH="${PATH}:/root/.dotnet/tools"

# Copy everything else and build
COPY . /src

RUN automatica-cli setversion $VERSION -W /src/Automatica.Core.Supervisor/
RUN dotnet publish -c Release -o /app/supervisor /src/Automatica.Core.Supervisor/ -r linux-x64

RUN cp /src/Automatica.Core.Supervisor/Automatica.Core.Supervisor/appsettings.json /app/supervisor/appsettings.json
RUN rm -rf /src


FROM automaticacore/automatica-plugin-standalone:amd64-latest AS runtime
WORKDIR /app/supervisor

COPY --from=build /app/supervisor ./
ENTRYPOINT ["/app/supervisor/Automatica.Core.Supervisor"]