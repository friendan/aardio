const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

rl.on('line', function(line) {
    handleJsonRpc(line);
});

function handleJsonRpc(json) {
    let request;
    try {
        request = JSON.parse(json);
    } catch (e) {
        console.log(JSON.stringify({ jsonrpc: "2.0", error: { code: -32700, message: "Parse error" }, id: null }));
        return;
    }

    if (!request || !request.method) {
        console.log(JSON.stringify({ jsonrpc: "2.0", error: { code: -32600, message: "Invalid Request" }, id: request.id }));
        return;
    }

    const params = request.params || [];
    
    try { 
        var func = eval("global."+request.method)
        if (typeof func === 'function') {
            const result =  func(...params);
            console.log(JSON.stringify({ jsonrpc: "2.0", result: result, id: request.id }));
        }    
        else { 
            console.log(JSON.stringify({ jsonrpc: "2.0", error: { code: -32601, message: "Method not found" }, id: request.id }));
        } 
    } catch (e) {
        console.log(JSON.stringify({ jsonrpc: "2.0", error: { code: -32601, message: e.message }, id: request.id }));
    }
}