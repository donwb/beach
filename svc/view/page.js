

const requestUpdate = async() => {
    const response = await fetch('/rampstatus');
    const json = await response.json();

    console.log(json)
    //modifyPage(json)
    modifyChatPage(json)
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