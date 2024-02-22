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
$(info $$GISHOST is [${GISHOST}])

all:
	python3 main.py

data: 
	python3 data.py

