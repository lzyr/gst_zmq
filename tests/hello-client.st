(ZMQ.Socket connect: 'tcp://localhost:5555')
sendReceive: 'hello' handler: [ :response | response printNl ]; close.
