# this really isn't used in production, it's just to test loading the database with some data

import psycopg2
import os

database = os.environ.get('DATABASE')
dbuser = os.environ.get('DBUSER')
host = os.environ.get('HOST')
password = os.environ.get('PASSWORD')
port = os.environ.get('PORT')

conn = psycopg2.connect(database = database, 
                        user = dbuser, 
                        host= host,
                        password = password,
                        port = port)

cur = conn.cursor()
cur.execute("""
INSERT INTO rampstatus(ramp_name, access_status, o_id, city, access_id, location)
VALUES
	(%s, %s, %s, %s, %s, %s)
ON CONFLICT(o_id)
DO UPDATE SET
    ramp_name = EXCLUDED.ramp_name,
    access_status = EXCLUDED.access_status,
    city = EXCLUDED.city,
    access_id = EXCLUDED.access_id,
    location = EXCLUDED.location;"""
            , ('Test Ramp', 'open', 1, 'Sarasota', 1, 'Siesta Key'))

conn.commit()
cur.close()
conn.close()

