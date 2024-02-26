package main

import "html/template"

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
