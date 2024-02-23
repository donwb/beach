package main

import (
	"github.com/labstack/echo/v4"
)

func homeHandler(c echo.Context) error {

	return c.String(200, "nothing to see here.......")

}

func rampStatusHandler(c echo.Context) error {

	rampStatusResponse := getAllRamps()

	return c.JSONPretty(200, rampStatusResponse, " ")

}
