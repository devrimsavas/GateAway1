# The Basic Gateway Microservice Tutorial

This tutorial demonstrates the basic usage of microservices. It shows how to connect different frameworks and facilitate communication via a gateway.

The application generates a random number using an ASP.NET Core backend. The gateway forwards this number to a Node.js server, which calculates the square of the number and sends the result back. The process is kept as simple as possible to demonstrate the core functionality of microservice communication.

## Structure

- **Gateway Folder**: Written in Node.js. This folder contains the gateway app that manages communication between the services. Since the app uses `concurrently`, you do not need to run the other services manually.
- **ProducerRandomNumber Folder**: This folder contains the ASP.NET Core service, which generates an array of random numbers but sends only one number to the gateway.

- **GetNumbers Folder**: This folder contains the Node.js service, which takes the number received from the ASP.NET Core service and returns the square of that number.

The client function on the gateway interface processes the data and dynamically displays the result in a table.

## Setup Instructions

1. **Install Node.js Packages**:
   Navigate to each folder that requires Node.js and run the following:

   ```bash
   npm install
   ```

2. **Restore ASP.NET Core Packages**:
   Navigate to the `ProducerRandomNumber` folder and restore packages:

   ```bash
   dotnet restore
   ```

3. **Run the Application**:
   In the `gateway` folder, the app is configured to run all services using `concurrently`. You don’t need to start the services individually. Simply run:

   ```bash
   npm run dev
   ```

   This will run:

   - The ASP.NET Core service to produce the random number.
   - The Node.js service to calculate the square of the number.
   - The gateway to manage the communication between them.

   Ensure you adjust your folders accordingly if you use a different setup (like Python or other frameworks).

## Important Note

Make sure to install `concurrently` to avoid having to activate each folder manually. Here’s the relevant section of the `package.json` script for this project:

```json
"scripts": {
  "start": "node ./bin/www",
  "start:aspnet": "dotnet run --project ../producerandomnumber",
  "start:node": "npm start --prefix ../getnumbers",
  "dev": "concurrently \"npm run start:aspnet\" \"npm run start:node\" \"npm start\""
}
```

Adjust the paths according to your project structure. If you're using a different framework (such as Python or another language), adapt the package handling as needed.

## DOCKER

### 1- Create a docker file

```bash
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
```

### 2- Build docker file

do not forget to run build from the main folder

build
` docker build -t gateway-tutorial .`

run

`docker run -p 8000:8000 -p 3001:3001 -p 5198:5198 gateway-tutorial `

## Author

Written by Devrim Savas Yilmaz for educational purposes.
