

const requestUpdate = async() => {
    const response = await fetch('/rampstatus');
    const tideResponse = await fetch('/tides');
    const json = await response.json();
    const tideJson = await tideResponse.json();

    console.log(json)
    //modifyPage(json)
    modifyChatPage(json)
    getTideInfo(tideJson)
}

function getTideInfo(json) {
    console.log("In getTideInfo")

    const waterTemp = json.waterTemp;
    const tidePercentage = json.tideLevelPercentage;
    const tideDirection = json.currentTideHighOrLow;

    const waterTempElement = document.getElementById("water-temp");
    const tideDirectionElement = document.getElementById("tide-dir");
    const tidePercentageElement = document.getElementById("tide-percentage");


    waterTempElement.innerHTML = waterTemp + '°F';
    tideDirectionElement.innerHTML = tideDirection;
    tidePercentageElement.innerHTML = tidePercentage + '%';

    console.log(json);

    const nextTideInfoElement = document.getElementById("next-tide-info");
    for (const tide of json.tideInfo) {
        const tideDirection = tide.highOrLow;
        const tideTime = tide.tideDateTime
        const tideDisplayDirection = tideDirection === 'H' ? 'High' : 'Low';
        dateTest = new Date(tideTime);
        const tideDisplayTime = dateTest.toLocaleTimeString();

        const newDiv = document.createElement('div');
        newDiv.innerHTML = "-- " + tideDisplayDirection + ' at ' + tideDisplayTime;
        nextTideInfoElement.appendChild(newDiv);
    }
}

function modifyPage(pageData) {

     for (const ramp of pageData) {
        if (ramp.city.toLowerCase() === 'new smyrna beach') {
            console.log(ramp);

            dotColor = getDotColor(ramp.accessStatus);

            const trackElem = document.querySelector("#ramps");
            console.log(trackElem);

            var elem = document.createElement('div');
            elem.className = 'rampName';
            elem.innerHTML = ' <span class=' + dotColor +' ></span> - ' + ramp.rampName;

            trackElem.appendChild(elem);


        }
     }
    
}

function modifyChatPage(pageData) {
    for (const ramp of pageData) {
        if (ramp.city.toLowerCase() === 'new smyrna beach') {
            console.log(ramp);

            dotColor = getDotColor(ramp.accessStatus);

            const rampList = document.getElementById("ramps");
            //console.log(rampList);

            var elem = document.createElement('li');
            var spanForDot = document.createElement('span');
        
            spanForDot.classList.add('dot', dotColor);
            //spanForDot.classList.add(dotColor);
            console.log(spanForDot);

            elem.appendChild(spanForDot);
            
            var accessStatus = ramp.accessStatus;
            var rampName = document.createTextNode(ramp.rampName + ' - ' + accessStatus);
            elem.appendChild(rampName);

            rampList.appendChild(elem);
            //elem.textContent = ramp.rampName;

            //document.getElementById('friendsList').appendChild(li);
            console.log(rampList)
        }
    }
}


function getDotColor(status) {
    outputColor = 'greydot';

    switch(status.toLowerCase()) {
        case 'open':
            outputColor = 'green';
            break;   
        case 'closed':
            outputColor = 'red';
            break;
        case 'closing in progress', '4x4 only':
            outputColor = 'yellow';
            break;
        default:
            outputColor = 'grey';
    }
    
    return outputColor;
}



(function() {
                
    // setInterval(
    //     requestUpdate,
    //     5000
    // );
    
   requestUpdate()
})();