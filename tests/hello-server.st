socket := ZMQ.Socket bind: 'tcp://*:5555'.
run := true.
[ run ] whileTrue: [ socket receiveInto: [ :request | request printNl. 
    request = 'quit' ifTrue: [ run := false. 'bye' ] ifFalse: [ ' world' ]]].
socket close.

