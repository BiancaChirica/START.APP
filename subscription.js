function subscribeManager(addr,contract)
{
    if(addr===undefined || addr===null)
    {
        return;
    }
    contract.events.NotifyManagerProductFinishDev({
        filter: {_managerAddress: addr},
        fromBlock:'latest'
    }, function(error, event)
    { 
        Swal.fire({
            title: 'Congrats!',
            text: 'One of your products was finished, product id :'+event['returnValues']['_productId'],
            icon: 'success',
            confirmButtonText: 'Yay!'
        });
        console.log(event + "\nabc"); 
        console.log(error);
    }
    );

}

function subscribeEvaluator(addr,contract)
{
    if(addr===undefined || addr===null)
    {
        return;
    }
    contract.events.NotifyEvaluator({
        filter: {_managerAddress: addr},
        fromBlock:'latest'
    }, function(error, event)
    { 
        Swal.fire({
            title: 'Info!',
            text: 'A product needs evaluating',
            icon: 'info',
            confirmButtonText: 'Yay!'
        });
        console.log(event + "\nabc"); 
        console.log(error);
    }
    );

}
function displayFinishedProducts()
{
myContract.myEvent({}, { fromBlock: 0, toBlock: 'latest' }).get((error, eventResult) => {
    if (error)
      console.log('Error in myEvent event handler: ' + error);
    else
      console.log('myEvent: ' + JSON.stringify(eventResult.args));
  });
}

function displayFinishedProducts(addr,contract)
{
    if(addr===undefined || addr===null)
    {
        return;
    }
    contract.events.NotifyManagerProductFinishDev({
        filter: {_managerAddress: addr},
        fromBlock:0,
        toBlock:'latest'}
    ).on(
        'data', function(event) {
        console.log(event);
      })
}