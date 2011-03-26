socket := ZMQ.Socket bind: 'tcp://*:5555'.
socket while: [ true ] receiveSend: [ :request | request printNl. ' world' ].
socket close.

