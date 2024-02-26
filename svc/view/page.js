

const requestUpdate = async() => {
    const response = await fetch('/rampstatus');
    const json = await response.json();

    console.log(json)
    modifyPage(json)
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

function getDotColor(status) {
    outputColor = 'greydot';

    switch(status.toLowerCase()) {
        case 'open':
            outputColor = 'greendot';
            break;   
        case 'closed':
            outputColor = 'reddot';
            break;
        case 'closing in progress', '4x4 only':
            outputColor = 'yellowdot';
            break;
        default:
            outputColor = 'greydot';
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