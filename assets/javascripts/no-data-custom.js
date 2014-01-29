  (function () {

    var chart,
        btnRemove = $('#remove'),
        btnAdd = $('#add'),
        btnShow = $('#showCustom');

    btnAdd.click(function () {                      
        chart.series[0].addPoint(Math.floor(Math.random() * 10 + 1)); 
    });

    btnRemove.click(function () {     
        if(chart.series[0].points[0]) {
            chart.series[0].points[0].remove();
        }
    });

    // Show a custom message
    btnShow.click(function () {
        if(!chart.hasData()) {  // Only if there is no data
            chart.hideNoData(); // Hide old message
            chart.showNoData("No Results Found");
        }
    });

    $('#container').highcharts({
        title: {
            text: 'Analytics For Group/All Users Billable vs Billed vs Unbilled Hours'
        },
        series: [{
            type: 'pie',
            name: 'Data Parameters',  
            data: []     
        }],            
        lang: {
            // Custom language option            
            noData: "No Results Availible"    
        },
        /* Custom options */
        noData: {
            // Custom positioning/aligning options
            position: {	
                //align: 'right',
                //verticalAlign: 'bottom'
            },
            // Custom svg attributes
            attr: {
                'stroke-width': 0,
                 stroke: '#cccccc'
            },
            // Custom css
            style: {                    
                fontWeight: 'bold',     
                fontSize: '35px',
                //color: '#202030'        
            }
        }
    });

    chart = $('#container').highcharts();
});