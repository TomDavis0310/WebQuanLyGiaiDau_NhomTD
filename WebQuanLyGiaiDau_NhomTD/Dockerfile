# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["WebQuanLyGiaiDau_NhomTD.csproj", "./"]
RUN dotnet restore "WebQuanLyGiaiDau_NhomTD.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "WebQuanLyGiaiDau_NhomTD.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "WebQuanLyGiaiDau_NhomTD.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Expose port (Render will automatically assign the PORT environment variable)
EXPOSE 8080

# Copy published files from publish stage
COPY --from=publish /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Entry point
ENTRYPOINT ["dotnet", "WebQuanLyGiaiDau_NhomTD.dll"]
