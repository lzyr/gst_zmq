socket := ZMQ.Socket connect: 'tcp://localhost:5555'.
socket sendReceive: 'hello' handler: [ :response | response printNl ].
socket close.
