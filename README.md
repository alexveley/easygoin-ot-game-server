# easygoin-ot-game-server

Docker image and Pterodactyl egg for **The Forgotten Server (TFS)** game server only. Used together with [easygoin-ot-web-server](https://github.com/alexveley/easygoin-ot-web-server) for the MyAAC web panel.

## Database (Pterodactyl-managed)

Create the database for **this** server in the Pterodactyl panel (Databases tab of the TFS server). Copy the connection details (host, port, database name, username, password) into the server's Startup Variables so TFS can connect. The MyAAC web server will use the **same** credentials (copy from here) so both share one database.

## Build

```bash
docker build -t easygoin-ot-game-server:latest .
```

## Run (standalone test)

```bash
docker run --rm -e MYSQL_HOST=host.docker.internal -e MYSQL_USER=root -e MYSQL_PASSWORD=xxx -e MYSQL_DATABASE=forgottenserver -v /path/to/server/data:/home/container easygoin-ot-game-server:latest
```

## Pterodactyl

Import the egg from `egg-tfs-game-server.json` into your nest. The egg expects the server root to contain TFS datapack (`data/`), `config.lua`, and `schema.sql` (installed by the egg's installation script).
