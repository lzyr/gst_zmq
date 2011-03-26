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

Object subclass: Server [
    | context socket |
    
    <comment: 'ZMQ server.'>
    <category: 'ZMQ'>

    "Class variables."
    zmq := ZMQ.Core new.
    globalContext := nil.
    contextRefs := 0.
            
    Server class >> open: connectionString [
        | instance |
        <category: 'intialization'>
        
        instance := super new.
        instance context: (Server globalContext_).        
        (instance context) ifNil: [ SystemExceptions.CInterfaceError signal: 'Context is nil.' ].
        instance initSocket_: connectionString.
        Server addContextRef_.
        ^instance.
    ]

    close [
        zmq close: socket.
        context == globalContext ifTrue: [ Server releaseContextRef_ ].
    ]

    receiveInto: aRequestHandlerBlock withFlags: intFlags [
        | requestString responseString |
        <category: 'networking'>
        
        requestString := zmq recv_string: socket flags: intFlags.
        responseString := aRequestHandlerBlock value: requestString.
        zmq send_string: socket string: responseString flags: intFlags.
    ]

    receiveInto: aRequestHandlerBlock [
        <category: 'networking'>
        self receiveInto: aRequestHandlerBlock withFlags: 0.
    ]

    context: aContext [ 
        <category: 'modifiers'>
        context := aContext. 
    ]

    context [ 
        <category: 'accessors'>
        ^context. 
    ]

    initSocket_: connectionString [
        <comment: 'Initializes the default REPLY socket.'>
        <category: 'private'>

        socket := zmq socket: context type: (zmq REP).
        socket ifNil: [ SystemExceptions.CInterfaceError signal: 'Failed to initialize socket.' ].
        (zmq bind: socket endPoint: connectionString) == 0
            ifFalse: [ SystemExceptions.CInterfaceError signal: 'Failed to bind socket. ', (zmq strerror: (zmq errno)) ].
    ]

    Server class >> globalContext_ [
        <category: 'class private'>
        globalContext ifNil: [ globalContext := zmq init: 1 ].
        ^globalContext.
    ]

    Server class >> zmq_ [
        <category: 'class private'>
        ^zmq.
    ]   

    Server class >> addContextRef_ [
        <category: 'class private'>
        contextRefs := contextRefs + 1.
    ]

    Server class >> releaseContextRef_ [
        <category: 'class private'>
        contextRefs := contextRefs - 1.
        contextRefs <= 0 ifTrue: [ Server termContext_. ]
    ]

    Server class >> termContext_ [
        globalContext == nil ifFalse: [ zmq term: globalContext. 
                                        globalContext := nil.
                                        contextRefs := 0. ]
    ]
    
] "Class Server"
] "Namespace ZMQ"
