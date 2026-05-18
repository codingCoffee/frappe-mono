
# Frappe Docker Minimal

## Initial Setup

This is a one time initial setup. Execute these commands once to setup frappe-bench

```sh
git clone https://github.com/codingCoffee/frappe-docker-minimal
cd frappe-docker-minimal

cp .mariadb.env.example .mariadb.env

docker compose -f docker-compose.prod.yml build
sh init_script.sh

docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml logs -f
```

## Executing Bench Commands

For subsequently executing any bench command you'll have to exec into the web-app container and execute the commands

- To exec you can use

```sh
docker compose -f docker-compose.prod.yml exec web-app bash
```

- For setting up a new site

```sh
bench new-site site-name.com
bench --site site-name.com build
bench --site site-name.com migrate
```

- For setting up a new site with erpnext as well

```sh
bench --site site-name.com install-app erpnext
```

- For restoring another site

```sh
bench --site site-name.com restore /tmp/frappe-backup/20260513_113737-frontend-database.sql.gz --with-public-files /tmp/frappe-backup/20260513_113737-frontend-files.tar --with-private-files /tmp/frappe-backup/20260513_113737-frontend-private-files.tar
bench --site site-name.com build
bench --site site-name.com migrate
```

- To reset admin password

```sh
bench --site site-name.com set-admin-password admin
bench restart
```

- To delete a site

```sh
bench drop-site site-name.com
bench drop-site site-name.com --no-backup
```

