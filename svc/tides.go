package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type NOAAUrlType int

const (
	DailyTides NOAAUrlType = iota // iota starts at 0
	WaterTemp
	WaterTempJax
)

func getTideInfo() []TideInfo {

	fmt.Println("Tides Handler")

	tidesURL := constructURL(DailyTides)

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

func constructURL(urlType NOAAUrlType) string {

	// tides:
	// https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=20240415&end_date=20240416&station=8721164&product=predictions&datum=MLLW&time_zone=lst_ldt&interval=hilo&units=english&format=json
	// water temp:
	// https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=20240415&end_date=20240415&station=8721604&product=water_temperature&time_zone=lst_ldt&interval=h&units=english&format=json

	baseURL := "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter"
	params := url.Values{}

	layout := "20060102"
	today := time.Now()
	formattedToday := today.Format(layout)

	params.Add("begin_date", formattedToday)
	params.Add("end_date", formattedToday)
	params.Add("time_zone", "lst_ldt")
	params.Add("units", "english")
	params.Add("format", "json")

	switch urlType {
	case DailyTides:
		params.Add("station", "8721164")
		params.Add("product", "predictions")
		params.Add("datum", "MLLW")
		params.Add("interval", "hilo")
	case WaterTemp:
		params.Add("station", "8721604")
		params.Add("product", "water_temperature")
		params.Add("interval", "h")
	case WaterTempJax:
		params.Add("station", "8720218")
		params.Add("product", "water_temperature")
		params.Add("interval", "h")
	}

	tidesURL := baseURL + "?" + params.Encode()
	fmt.Println(tidesURL)
	return tidesURL
}

func getNextHighAndLowTides(tideInfo TideInfoFromNOAA) []TideInfo {
	var outputTideInfo []TideInfo

	fmt.Println("Tide Info: ", tideInfo)

	if len(tideInfo.Predictions) == 0 {
		fmt.Println("No tide info")
		return outputTideInfo
	}

	for _, t := range tideInfo.Predictions {
		layout := "2006-01-02 15:04"
		timeWithTimeZone := t.TideDateTime // + " EDT"

		//parsedTime, err := time.ParseInLocation(layout, timeWithTimeZone, time.Local)
		loc, _ := time.LoadLocation("America/New_York")
		parsedTime, err := time.ParseInLocation(layout, timeWithTimeZone, loc)
		checkError(err, "Error parsing time")

		// This calculation is not working right for dates other than today
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

func getWaterTemp() (int, int) {

	//https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=20240415&end_date=20240415&station=8721604&product=water_temperature&time_zone=lst_ldt&interval=h&units=english&format=json
	url := constructURL(WaterTemp)
	jaxUrl := constructURL(WaterTempJax)

	// Get water temp from Canaveral
	resp, err := http.Get(url)
	checkError(err, "WaterTemp:: Error getting response")

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	checkError(err, "WaterTemp:Canaveral: Error reading response body")

	var waterTempFromNOAA WaterTempFromNOAA
	err = json.Unmarshal(body, &waterTempFromNOAA)
	checkError(err, "WaterTemp:Canaveral: Error unmarshalling json")

	// Get water temp from Jax
	jaxResp, err := http.Get(jaxUrl)
	checkError(err, "WaterTemp:Jax: Error getting response")

	defer jaxResp.Body.Close()

	jaxBody, err := ioutil.ReadAll(jaxResp.Body)
	checkError(err, "WaterTemp:: Error reading response body")

	var jaxWaterTempFromNOAA WaterTempFromNOAA
	err = json.Unmarshal(jaxBody, &jaxWaterTempFromNOAA)
	checkError(err, "WaterTemp:Jax: Error unmarshalling json")

	// convert water temp to int
	waterTemp := waterTempToInt(waterTempFromNOAA)
	jaxWaterTemp := waterTempToInt(jaxWaterTempFromNOAA)

	return waterTemp, jaxWaterTemp
}

func waterTempToInt(waterTempFromNOAA WaterTempFromNOAA) int {
	tempToUse := waterTempFromNOAA.Data[6].V
	decimalIndex := strings.Index(tempToUse, ".")
	strTemp := tempToUse[:decimalIndex]

	waterTemp, err := strconv.Atoi(strTemp)
	checkError(err, "WaterTemp:: Error converting water temp to int")
	return waterTemp
}

func computeTideDirection(info TideInfo) string {
	// the current tide status is the opposite of the next tide

	if info.HighOrLow == "H" {
		return "Rising"
	} else {
		return "Dropping"

	}
}

func computeTidePercentage(info TideInfo) int {
	const tideMinuteLength = 372
	loc, _ := time.LoadLocation("America/New_York")

	nextTideTime := info.TideDateTime
	nowTime := time.Now().In(loc)

	// break down the time into hours and minutes
	nowHour := nowTime.Hour()

	nextTideHour := nextTideTime.Hour()
	rawHourDiff := (nextTideHour - nowHour) - 1
	var hourDiff int
	if rawHourDiff < 0 {
		hourDiff = 0
	} else {
		hourDiff = rawHourDiff
	}

	fmt.Println("Now Hour: ", nowHour, " Next Tide Hour: ", nextTideHour, " Hour Diff: ", hourDiff, " Raw Hour Diff: ", rawHourDiff)

	var nowMinutes int
	tideMinutes := nextTideTime.Minute()
	if rawHourDiff < 0 {
		nowMinutes = 0
	} else {
		nowMinutes = 60 - nowTime.Minute()
	}
	//nowMinutes := 60 - nowTime.Minute()

	fmt.Println("Tide Minutes: ", tideMinutes, " Now Minutes: ", nowMinutes)

	// using the constant tideMinuteLength, calculate the percentage of the tide that has passed
	totalMinutesToNextTide := (((hourDiff * 60) + tideMinutes) + nowMinutes)
	fmt.Println("Total Minutes to Next Tide: ", totalMinutesToNextTide)

	minutesSinceLastTide := tideMinuteLength - totalMinutesToNextTide
	percentage := (float64(minutesSinceLastTide) / float64(tideMinuteLength)) * 100

	intPercentage := int(percentage)

	return intPercentage
}
