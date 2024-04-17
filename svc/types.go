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
	TideLevelPercentage  string     `json:"tideLevelPercentage"`
	WaterTemp            string     `json:"waterTemp"`
	TideInfo             []TideInfo `json:"tideInfo"`
}
