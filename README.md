
# Frappe Mono

A minimal dockerized Frappe / ERPNext setup. This is not the official
dockerized distribution, it's an opinionated setup and should only be used
if you understand the internal workings of Frappe.

## Initial Setup

This is a one time initial setup. Execute these commands once to setup frappe-bench

```sh
git clone https://github.com/codingCoffee/frappe-mono
cd frappe-mono

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

## Commonly used commands

Note: All these commands are to be executed inside the docker container

- For setting up a new site

```sh
bench new-site site-name.com
bench --site site-name.com build
bench --site site-name.com migrate
```

- For setting up a new site with erpnext as well

```sh
bench get-app --branch v15.106.0 https://github.com/frappe/erpnext
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

- Upgrade an app post initial setup (example assumes erpnext)

```sh
cd apps/erpnext
git fetch --tags
git checkout v15.106.0
./env/bin/pip install -q -U -e apps/erpnext

bench build --app erpnext
bench --site site-name.com migrate
bench --site site-name.com clear-cache
bench --site site-name.com build
bench restart
```
