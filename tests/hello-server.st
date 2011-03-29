(ZMQ.Socket bind: 'tcp://*:5555') while: [ true ] receiveSend: [ :request | request printNl. ' world' ]; close.

