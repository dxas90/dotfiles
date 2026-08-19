int = function(x){return parseInt(x)},
float = function(x){return parseFloat(x)}
out = {
    buff : "",
    print : function(x){this.buff+=(x).toString();},
    close : function(){process.stdout.write(this.buff);},
}
// When I wrote this, only God and I understood what I was doing
// Now, God only knows
solve = function (data) {
    out.print(data)
}

process.stdin.resume();
process.stdin.setEncoding('utf8');
process.stdin.on('data',function(data){solve(data);out.close();});
process.stdin.on('end', function () {process.exit();});

// ex: ts=4 sw=4 et filetype=sh

