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

DLD addLibrary: 'libzmq'.
DLD addLibrary: 'libgstzmq'.

Object subclass: #ZMQ.

ZMQ extend [

    init: anInt [
        <cCall: 'zmq_init' returning: #cObject args: #(#int)> 
    ]

    term: aPointer [
        <cCall: 'zmq_term' returning: #int args: #(#cObject)> 
    ]

    socket: aPointer type: anInt [
        <cCall: 'zmq_socket' returning: #cObject args: #(#cObject #int)> 
    ]

    connect: aPointer endPoint: aString [
        <cCall: 'zmq_connect' returning: #int args: #(#cObject #string)> 
    ]

    bind: aPointer endPoint: aString [
        <cCall: 'zmq_bind' returning: #int args: #(#cObject #string)> 
    ]

    close: aPointer [
        <cCall: 'zmq_close' returning: #int args: #(#cObject)> 
    ]

    send_string: aPointer string: aString flags: anInt [
        <cCall: 'gstzmq_send_string' returning: #int args: #(#cObject #string #int)> 
    ]

    recv_string: aPointer flags: anInt [
        <cCall: 'gstzmq_recv_string' returning: #stringOut args: #(#cObject #int)> 
    ]

    get_socket_type: aPointer [
        <cCall: 'gstzmq_getsockopt_type' returning: #int args: #(#cObject)> 
    ]

    errno [
        <cCall: 'zmq_errno' returning: #int args: #(#void)> 
    ]

    strerror [
        <cCall: 'zmq_strerror' returning: #string args: #(#int)> 
    ]

    version [
        <cCall: 'gstzmq_version' returning: #stringOut args: #(#void)> 
    ]

    "Constants"
    REQ [
        <cCall: 'gstzmq_REQ' returning: #int args: #(#void)> 
    ]

    REP [
        <cCall: 'gstzmq_REP' returning: #int args: #(#void)> 
    ]
]

