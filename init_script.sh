#!/usr/bin/env sh

frappe_container_name=frappe-temp

docker create --name "$frappe_container_name" codingcoffee/frappe-mono:prod
docker cp "$frappe_container_name:/home/frappe/frappe-bench/apps" ./apps
docker cp "$frappe_container_name:/home/frappe/frappe-bench/sites" ./sites
docker cp "$frappe_container_name:/home/frappe/frappe-bench/env" ./.venv
docker rm "$frappe_container_name"

