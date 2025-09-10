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

func tidesHandler(c echo.Context) error {

	outputTideInfo := getTideInfo()
	waterTemp, jaxWaterTemp := getWaterTemp()

	jax := WaterTempInfo{
		StationID:   "8720218",
		StationName: "Jacksonville",
		WaterTemp:   jaxWaterTemp,
	}
	canaveral := WaterTempInfo{
		StationID:   "8721604",
		StationName: "Canaveral",
		WaterTemp:   waterTemp,
	}

	var currentTide string
	var tideLevelPercentage int

	// Fix: properly check if tide data is available and valid
	if len(outputTideInfo) == 0 {
		fmt.Println("No tide information available")
		currentTide = "---"
		tideLevelPercentage = 0
	} else {
		// Additional safety check to ensure we have valid data
		firstTide := outputTideInfo[0]
		if !firstTide.TideDateTime.IsZero() {
			currentTide = computeTideDirection(firstTide)
			tideLevelPercentage = computeTidePercentage(firstTide)
		} else {
			fmt.Println("Invalid tide data - zero time")
			currentTide = "---"
			tideLevelPercentage = 0
		}
	}

	res := TideInfoResponse{
		CurrentTideHighOrLow: currentTide,
		TideLevelPercentage:  tideLevelPercentage,
		WaterTemp:            waterTemp,
		TideInfo:             outputTideInfo,
		WaterTemps:           []WaterTempInfo{canaveral, jax},
	}

	return c.JSON(200, res)

}
