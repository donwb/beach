import requests
import json
import psycopg2
import os


# database connection info
database = os.environ.get('DATABASE')
dbuser = os.environ.get('DBUSER')
host = os.environ.get('HOST')
password = os.environ.get('PASSWORD')
port = os.environ.get('PORT')

gis_host = os.environ.get('GISHOST')

# Volusia County Beach Ramps endpoint
base_url = "https://" + gis_host + "/arcgis/rest/services/Beaches/MapServer/7/query?"
query = "where=AccessStatus='$$$'&outFields=*&f=json"


def main():
    print("Starting the ramp status update process...")

    conn = psycopg2.connect(database = database, 
                        user = dbuser, 
                        host= host,
                        password = password,
                        port = port)

    query_ramps(base_url, query, conn)

    conn.close()

    
# Query the ramps based on the known statuses, then upsert the data into the database
def query_ramps(base_url, query, db_conn):
    statuses = ['open', 'closed for high tide', 'closed', '4x4 only', 'closing in progress', 'closed - cleared for turtles', 'closed - at capacity']


    for status in statuses:
        status_query = query.replace('$$$', status)
        url = base_url + status_query

        print(url)

        response = requests.get(url)

        data = json.loads(response.content)  
        ramps = data['features']

        for ramp in ramps:
            ramp_name = ramp['attributes']['AccessName']
            access_status = ramp['attributes']['AccessStatus']
            o_id = ramp['attributes']['OBJECTID']
            city = ramp['attributes']['City']
            access_id = ramp['attributes']['AccessID']
            location = ramp['attributes']['GeneralLoc']

            upsert_ramps(ramp_name, access_status, o_id, city, access_id, location, db_conn)
            

def upsert_ramps(ramp_name, access_status, o_id, city, access_id, location, db_conn):
    print('Upserting ' + ramp_name + ' into the database')

    cur = db_conn.cursor()
    cur.execute("""
    INSERT INTO rampstatus(ramp_name, access_status, o_id, city, access_id, location)
    VALUES
        (%s, %s, %s, %s, %s, %s)
    ON CONFLICT(access_id)
    DO UPDATE SET
        ramp_name = EXCLUDED.ramp_name,
        access_status = EXCLUDED.access_status,
        city = EXCLUDED.city,
        access_id = EXCLUDED.access_id,
        location = EXCLUDED.location;"""
                , (ramp_name, access_status, o_id, city, access_id, location))

    db_conn.commit()
    cur.close()

main()


