# Two-Server Setup (TFS + MyAAC)

The game server **owns** the database. Create one database in the panel for the TFS server, then reuse the same credentials for the MyAAC server so both use the same data.

## 1. Create the TFS game server

- In Pterodactyl, create a new server using the **TFS Game Server** egg.
- Assign allocations (e.g. **7171** for login, **7172** for game).
- Run **Install** so the egg installs the TFS datapack, config, and schema.

## 2. Create the database for the TFS server

- Open the TFS server in the panel.
- Go to the **Databases** tab.
- Click **Create Database**.
- Copy the connection details shown (host, port, database name, username, password). You need these for both servers.

## 3. Configure and start the TFS server

- Open the TFS server **Startup** (or **Variables**) and set:
  - **MySQL Host**, **MySQL Port**, **MySQL Database**, **MySQL User**, **MySQL Password** to the values from step 2.
- Start the TFS server. It will connect to the database and import `schema.sql` if the database is empty. Wait until the console shows `Forgotten Server Online`.

## 4. Create the MyAAC web server

- Create a new server using the **MyAAC Web Panel** egg.
- Assign one allocation (e.g. **8080** for HTTP).
- Run **Install** so the egg clones MyAAC and runs Composer.

## 5. Use the same database for MyAAC

- Open the MyAAC server **Startup** (or **Variables**).
- Paste the **same** database credentials from step 2:
  - **MySQL Host**, **MySQL Port**, **MySQL Database**, **MySQL User**, **MySQL Password** (same as the TFS server).
- Do **not** create a second database for the MyAAC server in the panel. MyAAC connects to the TFS server’s database.

## 6. Start the MyAAC server

- Start the MyAAC server.
- Open the server in a browser (e.g. `http://your-node-ip:8080`).
- If needed, complete MyAAC setup at `/install` (the database is already configured via variables).

---

**Note:** Database credentials are stored in the server’s Startup Variables and are visible to admins. Using Pterodactyl-managed databases keeps credentials scoped per server and avoids exposing MySQL to the public.
