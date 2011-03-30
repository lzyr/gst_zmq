(ZMQ.Socket connect: 'tcp://localhost:5555') sendReceive: 'newPoint' handler: 
    [ :point | ('point=',(point x) asString, ':', (point y) asString) printNl. ] 
    type: #object; 
close.
