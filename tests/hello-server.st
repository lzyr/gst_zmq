zmq := ZMQ new.
context := zmq init: 1.
context printNl.
socket := zmq socket: context type: (zmq REP).
socket printNl.
(zmq bind: socket endPoint: 'tcp://*:5555') printNl.
(zmq recv_string: socket flags: 0) printNl.
(zmq send_string: socket string: 'World!!' flags: 0) printNl.
(zmq close: socket) printNl.
zmq term: context.
