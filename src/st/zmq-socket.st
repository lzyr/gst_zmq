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
        instance initRepSocket_: connectionString.
        ^instance.
    ]

    Socket class >> connect: connectionString [
        | instance |
        <category: 'intialization'>
        <comment: 'Creates a ZMQ_REQ socket.'>
        
        instance := super new.
        instance context: (Socket newContext: 1) selfContext: true.
        (instance context) ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].
        instance initReqSocket_: connectionString.
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

    receive [
        <category: 'messaging'>

        ^ self receive: 0.
    ]

    receive: intFlags [
        <category: 'messaging'>

        ^ zmq recv_string: socket flags: intFlags.
    ]

    send: aString [
        <category: 'messaging'>

        ^ self send: aString flags: 0.
    ]

    send: aString flags: intFlags [
        <category: 'messaging'>

        ^ zmq send_string: socket string: aString flags: intFlags.
    ]

    receiveSend: aRequestHandlerBlock flags: intFlags [
        | requestString responseString |
        <category: 'messaging'>
        
        requestString := self receive: intFlags.
        responseString := aRequestHandlerBlock value: requestString.
        self send: responseString flags: intFlags.
    ]

    receiveSend: aRequestHandlerBlock [
        <category: 'messaging'>
        
        self receiveSend: aRequestHandlerBlock flags: 0.
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: intFlags [
        aPredicateBlock whileTrue: [ self receiveSend: aRequestHandlerBlock flags: intFlags ].
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock [
        aPredicateBlock whileTrue: [ self receiveSend: aRequestHandlerBlock flags: 0 ].
    ]

    sendReceive: aString handler: aResponseHandlerBlock flags: intFlags [
        <category: 'messaging'>
        
        self send: aString flags: intFlags.
        aResponseHandlerBlock value: (self receive: intFlags).
    ]

    sendReceive: aString handler: aResponseHandlerBlock [
        <category: 'messaging'>

        self sendReceive: aString handler: aResponseHandlerBlock flags: 0.
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

    initRepSocket_: connectionString [
        <comment: 'Initializes the default REP socket.'>
        <category: 'private'>

        socket := zmq socket: context type: (zmq REP).
        socket ifNil: [ SystemExceptions.CInterfaceError signal: 'Failed to initialize socket.' ].
        (zmq bind: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to bind socket. ', (zmq strerror: (zmq errno)) ].
    ]

    initReqSocket_: connectionString [
        <comment: 'Initializes the default REQ socket.'>
        <category: 'private'>

        socket := zmq socket: context type: (zmq REQ).
        socket ifNil: [ SystemExceptions.CInterfaceError signal: 'Failed to initialize socket.' ].
        (zmq connect: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to connect socket. ', (zmq strerror: (zmq errno)) ].
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
