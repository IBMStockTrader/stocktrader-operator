import * as https from 'node:https';

/**
 * Make an https call to polygon.io to get the price of the requested stock, and then
 * create a response JSON object in the format expected by the Stock Quote microservice.
 *
 * Note: Update the value of apiKey below with your real Polygon API Key.
 */
export const handler = (event, context, callback) => {
    console.log("event: ", event);
//  const symbol = 'KD';
    const symbol = event.params.path.symbol;
    console.log("symbol: ", symbol);
    const apiKey = 'abc123';
    const options = {
//      host: 'petstore.swagger.io',
        host: 'api.polygon.io',
//      path: '/v2/pet/findByStatus?status=available',
        path: '/v2/aggs/ticker/'+symbol+'/prev?adjusted=true&apiKey='+apiKey,
        port: 443,
        method: 'GET'
    };
    console.log("Options: ", options)
    let quote = {};
    const req = https.request(options, (res) => {
        let body = '';
        let chunk = '';
        console.log('Status:', res.statusCode);
        console.log('Headers:', JSON.stringify(res.headers));
        res.setEncoding('utf8');
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
            console.log('Successfully processed HTTPS response');
            // If we know it's JSON, parse it
            if (res.headers['content-type'] === 'application/json') {
                body = JSON.parse(body);
                console.log("Body: ", body)
                //example reply: {"ticker":"KD","queryCount":1,"resultsCount":1,"adjusted":true,"results":[{"T":"KD","v":1.437085e+06,"vw":23.198,"o":23.49,"c":23.21,"h":23.71,"l":23.055,"t":1724184000000,"n":14603}],"status":"OK","request_id":"af4d4c6c2480f357328e7e21ce395195","count":1}
                let result = body.results[0];
                console.log("Result: ", result);
                quote = {
                    "symbol": result.T, //ticker
                    "price": result.c, //closing price
                    "date": new Date(result.t).toISOString().substring(0, 10), //time, converted to a date
                    "time": result.t //time
                }
            } else {
                console.log("Content type was not JSON");
            }
            callback(null, quote);
        });
    });
    req.on('error', callback);
    req.write(JSON.stringify(quote));
    req.end();
};
