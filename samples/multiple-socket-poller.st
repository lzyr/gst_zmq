context := ZMQ.Core init: 1.

receiver := ZMQ.Socket connect: 'tcp://localhost:5557' type: #Pull context: context.
subscriber := ZMQ.Socket connect: 'tcp://localhost:5556' type: #Subscribe context: context.
subscriber subscribe: '10001 '.
"TODO: complete."
ZMQ.Core term: context.
