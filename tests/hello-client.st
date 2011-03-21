zmq := ZMQ new.
context := zmq init: 1.
context printNl.
socket := zmq socket: context type: (zmq REQ).
socket printNl.
(zmq connect: socket endPoint: 'tcp://localhost:5555') printNl.
(zmq send_string: socket string: 'Hello' flags: 0) printNl.
(zmq recv_string: socket flags: 0) printNl.
(zmq close: socket) printNl.
zmq term: context.
