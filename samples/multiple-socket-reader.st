context := ZMQ.Core init: 1.

receiver := ZMQ.Socket connect: 'tcp://localhost:5557' type: #Pull context: context.
subscriber := ZMQ.Socket connect: 'tcp://localhost:5556' type: #Subscribe context: context.
subscriber subscribe: '10001 '.
NOBLOCK := ZMQ.Core NOBLOCK.
[ true ] whileTrue: [ | task update |
                    task := receiver receive: NOBLOCK.
                    [ task = nil ] whileFalse: [ 
                    ('handling task: ', task) printNl.
                    Delay forMilliseconds: 500.
                    task := receiver receive: NOBLOCK ].            
                    
                    update: = subscriber receive: NOBLOCK.
                    [ update = nil ] whileFalse: [
                    ('handling update: ', update) printNl.
                    Delay forMilliseconds: 500.
                    update := subscriber receive: NOBLOCK ].
                    Delay forMilliseconds: 1000 ].

ZMQ.Core term: context.
