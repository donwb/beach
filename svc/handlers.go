package main

import (
	"fmt"

	"github.com/labstack/echo/v4"
)

func homeHandler(c echo.Context) error {

	return c.String(200, "nothing to see here.......")

}

func rampStatusHandler(c echo.Context) error {

	fmt.Println("Ramp Status Handler")

	rampStatusResponse := getAllRamps()

	return c.JSONPretty(200, rampStatusResponse, " ")

}
