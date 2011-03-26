server := ZMQ.Server open: 'tcp://*:5555'.
run := true.
requestHandler := [ :request | request printNl. 
    request = 'quit' 
        ifTrue: [ run := false. 'bye' ] 
    ifFalse: [ ' world' ]].
[ run ] whileTrue: [ server receiveInto: requestHandler ].
server close.

