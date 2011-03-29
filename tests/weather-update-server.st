(ZMQ.Socket bind: 'tcp://*:5556' type: #Publish) rebind: 'ipc://weather.ipc';
while: [ true ] send: [ zipcode := Random between: 0 and: 100000.
         temperature := (Random between: 0 and: 215) - 80.
         relhumidity := (Random between: 0 and: 50) + 10.
    (zipcode asString), ' ', (temperature asString), ' ', (relhumidity asString) ]; close.
