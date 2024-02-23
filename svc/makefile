#
# The include should be a single file that contains:
# export APIKEY := {APIKEY}
# export SECRET := {SECRET}
#
include env

$(info $$DATABASE is [${DATABASE}])
$(info $$DBUSER is [${DBUSER}])
$(info $$HOST is [${HOST}])
$(info $$PASSWORD is [${PASSWORD}])
$(info $$PORT is [${PORT}])

all:
	go run *.go

build: ## Build
	go build *.go

test: 
	gow -e=go,mod,html,js,css run .

docker-build:
	docker build --platform linux/amd64 -t donwb/beachsrv:0.1 .


docker-run:
	docker run --platform linux/amd64 --env-file=docker-env -p 80:1323 -it donwb/beachsrv:0.1

.DEFAULT_GOAL := all