package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"time"
)

func getTideInfo() []TideInfo {

	fmt.Println("Tides Handler")

	// https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=20240415&end_date=20240416&station=8721164&product=predictions&datum=MLLW&time_zone=lst_ldt&interval=hilo&units=english&format=json

	baseURL := "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter"
	params := url.Values{}

	// need to add actual dates
	params.Add("begin_date", "20240417")
	params.Add("end_date", "20240417")
	//

	params.Add("station", "8721164")
	params.Add("product", "predictions")
	params.Add("datum", "MLLW")
	params.Add("time_zone", "lst_ldt")
	params.Add("interval", "hilo")
	params.Add("units", "english")
	params.Add("format", "json")

	tidesURL := baseURL + "?" + params.Encode()
	fmt.Println(tidesURL)

	resp, err := http.Get(tidesURL)
	checkError(err, "Error getting response")

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	checkError(err, "Error reading response body")

	var tideInfo TideInfoFromNOAA
	err = json.Unmarshal(body, &tideInfo)
	checkError(err, "Error unmarshalling json")

	outputTideInfo := getNextHighAndLowTides(tideInfo)
	return outputTideInfo

}

func getNextHighAndLowTides(tideInfo TideInfoFromNOAA) []TideInfo {
	var outputTideInfo []TideInfo

	if len(tideInfo.Predictions) == 0 {
		fmt.Println("No tide info")
		return outputTideInfo
	}

	for _, t := range tideInfo.Predictions {
		layout := "2006-01-02 15:04"
		timeWithTimeZone := t.TideDateTime // + " EDT"

		parsedTime, err := time.ParseInLocation(layout, timeWithTimeZone, time.Local)
		checkError(err, "Error parsing time")

		if parsedTime.After(time.Now()) {
			tide := TideInfo{
				TideDateTime: parsedTime,
				HighOrLow:    t.HighOrLow,
			}
			outputTideInfo = append(outputTideInfo, tide)
		}

	}

	fmt.Println(outputTideInfo)
	return outputTideInfo
}
