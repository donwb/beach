load("render.star", "render")
load("time.star", "time")
load("cache.star", "cache")
load("http.star", "http")
load("encoding/json.star", "json")


DEFAULT_TEMP = 999

def main(config):
    
    print("STARTING.......")


    # setup fonts
    font = config.get("font", "tom-thumb")
    print("Using font: '{}'".format(font))

    #call api to get data before render
    # baseURL = "http://localhost:1323/current"
    baseURL = "https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus"
    api_result = http.get(url = baseURL)
    api_response = api_result.body()
    cache.set("temps", api_result.body(), ttl_seconds = 7200)   

    ramp_list = json.decode(api_response)
    # print(ramp_list)

    nsb_ramps = get_nsb_ramps(ramp_list)
    print(nsb_ramps)

    ramp_colors = set_ramp_colors(nsb_ramps)
    print(ramp_colors)



    return render.Root(
        render.Row(
            children=[
                render.Column(
                        expanded=True,
                        main_align="space_around",
                        cross_align="left",
                        children=[
                            render.Text("Beachway", color=ramp_colors["beachway"]),
                            render.Text("Crawford", color=ramp_colors["crawford"]),
                            render.Text("Flagler", color=ramp_colors["flagler"]),
                            render.Text("3rd Ave", color=ramp_colors["3rd"]),
                        ]
                )
            ]
        )
        
)

def get_nsb_ramps(ramp_list):
    nsb_ramps = {}
    crawford_ramp = [ramp for ramp in ramp_list if ramp["rampName"] == "CRAWFORD RD"]
    crawford = crawford_ramp[0]["accessStatus"]
    nsb_ramps["crawford"] = crawford

    beachway_ramp = [ramp for ramp in ramp_list if ramp["rampName"] == "BEACHWAY AV"]
    beachway = beachway_ramp[0]["accessStatus"]
    nsb_ramps["beachway"] = beachway

    flagler_ramp = [ramp for ramp in ramp_list if ramp["rampName"] == "FLAGLER AV"]
    flagler = flagler_ramp[0]["accessStatus"]
    nsb_ramps["flagler"] = flagler

    third_ramp = [ramp for ramp in ramp_list if ramp["rampName"] == "3RD AV"]
    third = third_ramp[0]["accessStatus"]
    nsb_ramps["3rd"] = third
    
    return nsb_ramps


def set_ramp_colors(nsb_ramp_dict):

    red = "#B81D13"
    yellow = "EFB700"
    green = "008450"

    colors_dict = {}

    if nsb_ramp_dict["crawford"] == "OPEN":
        crawford_color = green
    elif nsb_ramp_dict["crawford"] == "CLOSED":
        crawford_color = red
    else:
        crawford_color = yellow
    colors_dict["crawford"] = crawford_color

    if nsb_ramp_dict["beachway"] == "OPEN":
        beachway_color = green
    elif nsb_ramp_dict["beachway"] == "CLOSED":
        beachway_color = red
    else:
        beachway_color = yellow

    colors_dict["beachway"] = beachway_color

    if nsb_ramp_dict["flagler"] == "OPEN":
        flagler_color = green
    elif nsb_ramp_dict["flagler"] == "CLOSED":
        flagler_color = red
    else:
        flagler_color = yellow
    colors_dict["flagler"] = flagler_color

    if nsb_ramp_dict["3rd"] == "OPEN":
        third_color = green
    elif nsb_ramp_dict["3rd"] == "CLOSED":
        third_color = red
    else:
        third_color = yellow  
    colors_dict["3rd"] = third_color

    return colors_dict
