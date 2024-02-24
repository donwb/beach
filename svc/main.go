package main

import (
	"fmt"
	"os"

	"github.com/labstack/echo/v4"
)

var database string
var dbuser string
var host string
var password string
var dbport string

func main() {

	setupEnvVars()

	e := echo.New()
	e.GET("/", homeHandler)
	e.GET("/rampstatus", rampStatusHandler)
	e.GET("/ramps", rampsHandler)

	// Start!
	e.Logger.Fatal(e.Start(":1323"))
}

func setupEnvVars() {
	database = os.Getenv("DATABASE")
	dbuser = os.Getenv("DBUSER")
	host = os.Getenv("HOST")
	password = os.Getenv("PASSWORD")
	dbport = os.Getenv("DBPORT")

	fmt.Println("\n\n-------- ENVVARS ------------")
	fmt.Println("database: ", database)
	fmt.Println("dbuser:", dbuser)
	fmt.Println("Host:", host)
	fmt.Println("Password", password)
	fmt.Println("DBPort:", dbport)

}

func checkError(err error, msg string) {
	if err != nil {
		fmt.Println("--------------------")
		fmt.Println("PANIC: ", msg)
		panic(err)
	}
}
