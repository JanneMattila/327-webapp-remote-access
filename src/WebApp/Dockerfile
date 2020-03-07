#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# 1. Build image(https://hub.docker.com/_/microsoft-dotnet-core-sdk/)
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# SSH Configuration->
EXPOSE 2222
ENV SSH_PORT 2222
RUN apt-get update -qq && \
    apt-get dist-upgrade --no-install-recommends -y && \
    apt-get install -y --no-install-recommends openssh-server && \
    echo "root:Docker!" | chpasswd

COPY init_container.sh /bin/
RUN chmod 755 /bin/init_container.sh

COPY sshd_config /etc/ssh/
RUN mkdir -p /var/run/sshd
# <-SSH Configuration

# CRON Configuration->
RUN apt-get install -y --no-install-recommends cron
COPY mycron /etc/cron.hourly
RUN chmod 0644 /etc/cron.hourly/mycron
# <-CRON Configuration

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src

# Cache nuget restore
COPY ["src/WebApp/WebApp.csproj", "src/WebApp/"]
RUN dotnet restore "src/WebApp/WebApp.csproj"

# Copy sources and compile
COPY . .
WORKDIR "/src/src/WebApp"
RUN dotnet build "WebApp.csproj" -c Release -o /app/build

# 2. Release image
FROM build AS publish
RUN dotnet publish "WebApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app

# Copy content from Build image
COPY --from=publish /app/publish .
ENTRYPOINT ["/bin/init_container.sh", "dotnet", "WebApp.dll"]
