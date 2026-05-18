
# For prod setup


```sh
git clone https://github.com/codingCoffee/frappe-docker-minimal
cd frappe-docker-minimal

cp .mariadb.env.example .mariadb.env

docker compose -f docker-compose.prod.yml build
sh init_script.sh

docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml logs -f
```

# Restore

```
bench new-site site-name.com
bench --site site-name.com install-app erpnext
bench --site site-name.com build
bench --site site-name.com migrate

bench --site site-name.com restore /tmp/frappe-backup/20260513_113737-frontend-database.sql.gz --with-public-files /tmp/frappe-backup/20260513_113737-frontend-files.tar --with-private-files /tmp/frappe-backup/20260513_113737-frontend-private-files.tar
bench --site site-name.com build
bench --site site-name.com migrate

bench --site site-name.com set-admin-password admin
bench restart

bench drop-site site-name.com
bench drop-site site-name.com --no-backup
```
