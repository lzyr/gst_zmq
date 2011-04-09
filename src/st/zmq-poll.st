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

Object subclass: Poll [
    | pollInfo pollList |

    <comment: 'ZMQ poll.'>
    <category: 'ZMQ'>

    Poll class >> new [
        | this |
        <category: 'intialization'>
        
        this := super new.
        this init.
        ^ this.        
    ]

    init [
        <category: 'intialization'>

        pollInfo = nil.
        pollList = LinkedList new.
    ]

    add: aSocket event: aSym [
        | a |
        
        a := Array new: 2.
        a at: 1 put: aSocket.
        a at: 2 put: aSym.
        pollList add: a.        
    ]

    poll: timeoutMicroSeconds [
        | retSockets |

        pollInfo ifNil: [ pollInfo := ZMQ.Core init_poll_info: (pollList size).
        self add_to_pollinfo. ].
        ZMQ.Core poll: pollInfo timeout: timeoutMicroSeconds.
        retSockets := LinkedList new.
        "TODO: Check which socket has an event set. Add it to retSockets."
        ^ retSockets.
    ]
]
