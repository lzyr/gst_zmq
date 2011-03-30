sender := ZMQ.Socket bind: 'tcp://*:5557' type: #Push.
sender send: '0'.
100 timesRepeat: [ sender send: (Random between: 0 and: 100) asString ].
(Delay forSeconds: 1) wait.
sender close.

