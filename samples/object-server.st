(ZMQ.Socket bind: 'tcp://*:5555') while: [ true ] receiveSend: 
    [ :request | (Point new: (Random between: 1 and: 100) y: (Random between: 101 and: 200)) ] 
    type: #object; 
close.
