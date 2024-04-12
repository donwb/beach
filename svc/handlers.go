package main

import (
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

// func homeHandler(c echo.Context) error {

// 	return c.String(200, "nothing to see here.......")

// }

func rampStatusHandler(c echo.Context) error {

	fmt.Println("Ramp Status Handler")

	rampStatusResponse := getAllRamps()

	return c.JSONPretty(200, rampStatusResponse, " ")

}

func rampsHandler(c echo.Context) error {
	ramps := getAllRamps()
	retVal := ""

	for _, r := range ramps {
		rampName := r.RampName
		//fmt.Println("Ramp Name: ", rampName)
		accessStatus := r.AccessStatus
		//fmt.Println("Access Status: ", accessStatus)
		outString := fmt.Sprintf("%s is : %s\n", rampName, accessStatus)
		fmt.Println(outString)
		retVal += outString
	}
	//retVal := ramps + rs

	return c.String(200, retVal)
}

func indexHandler(c echo.Context) error {
	fmt.Println("Index Handler")
	return c.Render(http.StatusOK, "home.html", map[string]interface{}{
		"name": "Ramps",
		"msg":  "Ramp Info",
	})
}
