# Step 1: Build the ASP.NET Core app using .NET 8 SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-aspnet
WORKDIR /src
COPY producerandomnumber/producerandomnumber.csproj ./producerandomnumber/
RUN dotnet restore ./producerandomnumber/producerandomnumber.csproj
COPY producerandomnumber/ ./producerandomnumber/
WORKDIR "/src/producerandomnumber"
RUN dotnet build producerandomnumber.csproj -c Release -o /app/build
RUN dotnet publish producerandomnumber.csproj -c Release -o /app/publish

# Step 2: Build the Node.js gateway app
FROM node:16 AS build-gateway
WORKDIR /gateway
COPY gateway/package*.json ./    
RUN npm install --include=dev
COPY gateway/ ./  

# Step 3: Build the Node.js getnumbers app
WORKDIR /getnumbers
COPY getnumbers/package*.json ./    
RUN npm install
COPY getnumbers/ ./   

# Step 4: Final stage - Use .NET runtime and Node.js runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
# Install Node.js in the final stage
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

WORKDIR /app
COPY --from=build-aspnet /app/publish /app   
COPY --from=build-gateway /gateway /gateway
COPY --from=build-gateway /getnumbers /getnumbers

# Expose the necessary ports
EXPOSE 8000 3001 5198

# Start all services using concurrently
CMD ["npx", "concurrently", "\"dotnet /app/producerandomnumber.dll --urls http://0.0.0.0:5198\"", "\"npm start --prefix /getnumbers\"", "\"npm start --prefix /gateway\""]
