" ZMQ bindings for GNU Smalltalk. 
Copyright (C) 2011 by Vijay Mathew Pandyalakal<vijay.the.schemer@gmail.com> 

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the 'Software!'), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE. "

Namespace current: ZMQ [

Object subclass: Socket [
    | context selfContext socket |
    
    <comment: 'ZMQ server.'>
    <category: 'ZMQ'>

    "Class variables."
    zmq := ZMQ.Core new.
            
    Socket class >> bind: connectionString [
        | instance |
        <category: 'intialization'>
        <comment: 'Creates a ZMQ_REP socket.'>
        
        instance := super new.
        instance context: (Socket newContext: 1) selfContext: true.
        (instance context) ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].
        instance initSocket_: connectionString.
        ^instance.
    ]

    close [
        <category: 'deinitialization'>

        zmq close: socket.
        self deleteContext.
    ]

    deleteContext [
        <category: 'deinitialization'>

        context == nil ifFalse: [ selfContext ifTrue: [ Socket deleteContext: context. context := nil. ] ]
    ]

    receiveInto: aRequestHandlerBlock withFlags: intFlags [
        | requestString responseString |
        <category: 'messaging'>
        
        requestString := zmq recv_string: socket flags: intFlags.
        responseString := aRequestHandlerBlock value: requestString.
        zmq send_string: socket string: responseString flags: intFlags.
    ]

    receiveInto: aRequestHandlerBlock [
        <category: 'messaging'>

        self receiveInto: aRequestHandlerBlock withFlags: 0.
    ]

    context: aContext [ 
        <category: 'modifiers'>

        self context: aContext selfContext: false.
    ]

    context: aContext selfContext: aBoolean [
        <category: 'modifiers'>

        self deleteContext.
        context := aContext. 
        selfContext := aBoolean.
    ]

    context [ 
        <category: 'accessors'>

        ^context. 
    ]

    selfContext [ 
        <category: 'accessors'>

        ^selfContext. 
    ]

    initSocket_: connectionString [
        <comment: 'Initializes the default REPLY socket.'>
        <category: 'private'>

        socket := zmq socket: context type: (zmq REP).
        socket ifNil: [ SystemExceptions.CInterfaceError signal: 'Failed to initialize socket.' ].
        (zmq bind: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to bind socket. ', (zmq strerror: (zmq errno)) ].
    ]

    Socket class >> newContext: intIoThreads [
        <category: 'class methods'>

        ^ zmq init: intIoThreads.
    ]

    Socket class >> deleteContext: aContext [
        <category: 'class methods'>

        aContext == nil ifFalse: [ zmq term: aContext ]
    ]
    
] "Class Socket"
] "Namespace ZMQ"
