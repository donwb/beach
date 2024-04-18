package main

import (
	"html/template"
	"time"
)

type RampStatus struct {
	Id           int    `json:"id"`
	RampName     string `json:"rampName"`
	AccessStatus string `json:"accessStatus"`
	ObjectID     int    `json:"objectID"`
	City         string `json:"city"`
	AccessID     string `json:"accessID"`
	Location     string `json:"location"`
}

type TemplateRegistry struct {
	templates *template.Template
}

type TideInfoFromNOAA struct {
	Predictions []struct {
		TideDateTime string `json:"t"`
		Val          string `json:"v"`
		HighOrLow    string `json:"type"`
	} `json:"predictions"`
}

type TideInfo struct {
	TideDateTime time.Time `json:"tideDateTime"`
	HighOrLow    string    `json:"highOrLow"`
}

type TideInfoResponse struct {
	CurrentTideHighOrLow string     `json:"currentTideHighOrLow"`
	TideLevelPercentage  int        `json:"tideLevelPercentage"`
	WaterTemp            int        `json:"waterTemp"`
	TideInfo             []TideInfo `json:"tideInfo"`
}

type WaterTempFromNOAA struct {
	Metadata struct {
		ID   string `json:"id"`
		Name string `json:"name"`
		Lat  string `json:"lat"`
		Lon  string `json:"lon"`
	} `json:"metadata"`
	Data []struct {
		T string `json:"t"`
		V string `json:"v"`
		F string `json:"f"`
	} `json:"data"`
}
