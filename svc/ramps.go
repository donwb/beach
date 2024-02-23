package main

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

func getAllRamps() []RampStatus {

	connectString := getConnectString()

	fmt.Println("opening connection....")

	db, err := sql.Open("postgres", connectString)
	checkError(err, "opening connection")
	defer db.Close()

	rampsQuery := `select id, ramp_name, access_status, o_id, city, access_id, location
	from rampstatus order by city;`

	fmt.Println("running query....")

	rows, err := db.Query(rampsQuery)
	checkError(err, "Failed running ramp query")
	defer rows.Close()

	retVal := make([]RampStatus, 0)

	for rows.Next() {
		var id int
		var rampName string
		var accessStatus string
		var objectID int
		var city string
		var accessID string
		var location string

		err := rows.Scan(&id, &rampName, &accessStatus, &objectID, &city, &accessID, &location)
		checkError(err, "Error on scan")
		fmt.Println("Ramp name: " + rampName)

		aRampStatus := RampStatus{
			Id:           id,
			RampName:     rampName,
			AccessStatus: accessStatus,
			ObjectID:     objectID,
			City:         city,
			AccessID:     accessID,
			Location:     location,
		}

		retVal = append(retVal, aRampStatus)
	}

	fmt.Println("returning from getAllRamps")

	return retVal

}

func getConnectString() string {
	connInfo := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", host, dbport, dbuser, password, database)

	return connInfo
}
