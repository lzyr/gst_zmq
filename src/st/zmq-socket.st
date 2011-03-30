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

    Socket class >> bind: connectionString [
        <category: 'intialization'>
        <comment: 'Creates a ZMQ_REP socket.'>
        
        ^Socket bind: connectionString type: #Reply.
    ]

    Socket class >> bind: connectionString type: typeSymbol [
        | this |
        <category: 'intialization'>
        <comment: 'Creates and binds ZMQ socket.'>
        
        this := super new.
        this context: (Socket newContext: 1) selfContext: true.
        (this context) ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].
        this initBindSocket_: connectionString type: typeSymbol.
        ^this.
    ]

    Socket class >> bind: connectionString type: typeSymbol context: aContext [
        | this |
        <category: 'intialization'>
        <comment: 'Creates and binds ZMQ socket.'>

        aContext ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].        
        this := super new.
        this context: aContext selfContext: false.
        this initBindSocket_: connectionString type: typeSymbol.
        ^this.
    ]

    Socket class >> connect: connectionString [
        | this |
        <category: 'intialization'>
        <comment: 'Creates a ZMQ_REQ socket.'>
        
        ^Socket connect: connectionString type: #Request.
    ]

    Socket class >> connect: connectionString type: typeSymbol [
        | this |
        <category: 'intialization'>
        <comment: 'Creates and connects a ZMQ socket.'>
        
        this := super new.
        this context: (Socket newContext: 1) selfContext: true.
        (this context) ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].
        this initConnectSocket_: connectionString type: typeSymbol.
        ^this.
    ]

    Socket class >> connect: connectionString type: typeSymbol context: aContext [
        | this |
        <category: 'intialization'>
        <comment: 'Creates and connects a ZMQ socket.'>

        aContext ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].        
        this := super new.
        this context: aContext selfContext: false.
        this initConnectSocket_: connectionString type: typeSymbol.
        ^this.
    ]

    rebind: connectionString [
        <category: 'initialization'>
        
        self bind_: connectionString.
    ]

    subscribe: filterString [
        ZMQ.Core set_socket_subscribe: socket value: filterString.
    ]

    socket [
        ^ socket.
    ]

    close [
        <category: 'deinitialization'>

        Core close: socket.
        self deleteContext.
    ]

    deleteContext [
        <category: 'deinitialization'>

        context == nil ifFalse: [ selfContext ifTrue: [ Socket deleteContext: context. context := nil. ] ]
    ]

    receive [
        <category: 'messaging'>

        ^ self receive: 0 type: #string.
    ]

    receive: intFlags type: symType [
        <category: 'messaging'>

        symType = #string ifTrue: [ ^Core recv_string: socket flags: intFlags ]
        ifFalse: [ symType = #byteArray ifTrue: [ ^self receiveBytes: intFlags ]
                                        ifFalse: [ ^self receiveObject: intFlags ]].  
    ]

    receiveBytes: intFlags [
        | cObj bytes |
        <category: 'messaging'>

        cObj := Core recv_bytes: socket flags: intFlags.
        bytes := String fromCData: (Core bytes: cObj) size: (Core bytes_size: cObj).
        Core bytes_free: cObj.
        ^bytes.
    ]

    receiveBytes [
        <category: 'messaging'>

        ^self receiveBytes: 0.
    ]

    receiveObject: intFlags [  
        | bytes stream |           
        <category: 'messaging'>     
        
        bytes := self receiveBytes: intFlags.
        stream := bytes readWriteStream.
        stream reset.
        ^(ObjectDumper on: stream) load.
    ]

    receiveObject [
        <category: 'messaging'>     
        
        ^ self receiveObject: 0.
    ]

    send: anObject [
        <category: 'messaging'>

        ^self send: anObject flags: 0 type: #string.
    ]

    send: anObject flags: intFlags [
        <category: 'messaging'>

        ^self send: anObject flags: intFlags type: #string.
    ]

    send: anObject type: symType [
        <category: 'messaging'>

        ^self send: anObject flags: 0 type: symType.
    ]

    send: anObject flags: intFlags type: symType [
        <category: 'messaging'>

        ((symType = #string) or: [ symType = #byteArray ])
        ifTrue: [ ^Core send_bytes: socket bytes: anObject size: (anObject size) flags: intFlags. ]
        ifFalse: [ ^self sendObject: anObject flags: intFlags. ].
    ]

    sendObject: anObject flags: intFlags [
        | byteStream objDumper |
        byteStream := (String new) readWriteStream.
        objDumper := ObjectDumper on: byteStream.
        objDumper dump: anObject.
        byteStream reset.
        ^self send: (byteStream contents) flags: intFlags type: #byteArray.
    ]

    receiveSend: aRequestHandlerBlock flags: intFlags type: symType [
        | requestString responseString |
        <category: 'messaging'>
        
        requestString := self receive: intFlags type: symType.
        responseString := aRequestHandlerBlock value: requestString.
        ^self send: responseString flags: intFlags type: symType.
    ]

    receiveSend: aRequestHandlerBlock flags: intFlags [
        <category: 'messaging'>
        
        ^self receiveSend: aRequestHandlerBlock flags: intFlags type: #string.
    ]

    receiveSend: aRequestHandlerBlock [
        <category: 'messaging'>
        
        ^self receiveSend: aRequestHandlerBlock flags: 0 type: #string.
    ]

    receiveSend: aRequestHandlerBlock type: symType [
        <category: 'messaging'>
        
        ^self receiveSend: aRequestHandlerBlock flags: 0 type: symType.
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: intFlags type: symType [
        aPredicateBlock whileTrue: [ self receiveSend: aRequestHandlerBlock flags: intFlags type: symType ].
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: intFlags [
        self while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: intFlags type: #string.       
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock [
        self while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: 0 type: #string.       
    ]

    while: aPredicateBlock receiveSend: aRequestHandlerBlock type: symType [
        self while: aPredicateBlock receiveSend: aRequestHandlerBlock flags: 0 type: symType .       
    ]

    while: aPredicateBlock send: aResponseGeneratorBlock flags: intFlags type: symType [
        aPredicateBlock whileTrue: [ self send: (aResponseGeneratorBlock value) flags: intFlags type: symType ].
    ]

    while: aPredicateBlock send: aResponseGeneratorBlock flags: intFlags [
        self while: aPredicateBlock send: aResponseGeneratorBlock flags: intFlags type: #string.    
    ]

    while: aPredicateBlock send: aResponseGeneratorBlock type: symType [
        self while: aPredicateBlock send: aResponseGeneratorBlock flags: 0 type: symType.    
    ]

    while: aPredicateBlock send: aResponseGeneratorBlock [
        self while: aPredicateBlock send: aResponseGeneratorBlock flags: 0 type: #string.    
    ]

    sendReceive: aString handler: aResponseHandlerBlock flags: intFlags type: symType [
        <category: 'messaging'>
        
        self send: aString flags: intFlags type: symType.
        aResponseHandlerBlock value: (self receive: intFlags type: symType).
    ]

    sendReceive: aString handler: aResponseHandlerBlock flags: intFlags [
        <category: 'messaging'>
        
        self sendReceive: aString handler: aResponseHandlerBlock flags: intFlags type: #string.
    ]

    sendReceive: aString handler: aResponseHandlerBlock type: symType [
        <category: 'messaging'>
        
        self sendReceive: aString handler: aResponseHandlerBlock flags: 0 type: symType.
    ]

    sendReceive: aString handler: aResponseHandlerBlock [
        <category: 'messaging'>
        
        self sendReceive: aString handler: aResponseHandlerBlock flags: 0 type: #string.
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

    bind_: connectionString [
        <category: 'private'>
        
        (Core bind: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to bind socket. ', 
                           (Core strerror: (Core errno)) ].
    ]

    initSocket_: connectionString type: typeSymbol [
        <comment: 'Initializes a socket.'>
        <category: 'private'>
        
        socket := Core socket: context type: typeSymbol.
        socket ifNil: [ SystemExceptions.CInterfaceError signal: 'Failed to initialize socket.' ].
    ]

    initBindSocket_: connectionString type: typeSymbol [
        <comment: 'Initializes a socket.'>
        <category: 'private'>
        
        self initSocket_: connectionString type: typeSymbol.
        self bind_: connectionString.
    ]

    initConnectSocket_: connectionString type: typeSymbol [
        <comment: 'Initializes the default REQ socket.'>
        <category: 'private'>

        self initSocket_: connectionString type: typeSymbol.
        (Core connect: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to connect socket. ', 
                           (Core strerror: (Core errno)) ].
    ]

    Socket class >> newContext: intIoThreads [
        <category: 'class methods'>

        ^ Core init: intIoThreads.
    ]

    Socket class >> deleteContext: aContext [
        <category: 'class methods'>

        aContext == nil ifFalse: [ Core term: aContext ]
    ]
    
] "Class Socket"
] "Namespace ZMQ"
