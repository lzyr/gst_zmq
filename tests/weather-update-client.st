socket := ZMQ.Socket connect: 'tcp://localhost:5556' type: #Subscribe.
socket subscribe: '10001'.
10 timesRepeat: [ (socket receive) printNl ].
socket close.
