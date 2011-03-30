context := ZMQ.Socket newContext: 1.
receiver := ZMQ.Socket connect: 'tcp://localhost:5557' type: #Pull context: context.
sender := ZMQ.Socket connect: 'tcp://localhost:5558' type: #Push context: context.
[ true ] whileTrue: [ (Delay forMilliseconds: (receiver receive) asNumber) wait. 'task done' printNl. sender send: '' ].
receiver close.
sender close.
ZMQ.Socket deleteContext: context.
    
