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

Namespace current: ZMQ [

Object subclass: #Core. "[
    <comment: 'Low-level calls to the ZMQ library.'>
    <category: 'ZMQ'>
]."

Core extend [

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

    "polling."

    init_poll_info: anInt [
        <cCall: 'gstzmq_init_poll_info' returning: #cObject args: #(#int)> 
    ]

    delete_poll_info: aPointer [
        <cCall: 'gstzmq_delete_poll_info' returning: #void args: #(#cObject)> 
    ]

    poll_info_add: aPointer socket: aSocket fd: anInt events: aShort 
    revents: anotherShort [
        <cCall: 'gstzmq_poll_info_add' returning: #int 
                                       args: #(#cObject #cObject #int #int #int)>
    ]

    poll: aPointer timeout: aLong [
        <cCall: 'gstzmq_poll' returning: #int args: #(#cObject #long)> 
    ]

    "get/set socket options."

    get_socket_type: aPointer [
        <cCall: 'gstzmq_getsockopt_type' returning: #int args: #(#cObject)> 
    ]

    get_socket_rcvmore: aPointer [
        <cCall: 'gstzmq_getsockopt_rcvmore' returning: #int args: #(#cObject)> 
    ]

    get_socket_linger: aPointer [
        <cCall: 'gstzmq_getsockopt_linger' returning: #int args: #(#cObject)> 
    ]

    get_socket_reconnect_ivl: aPointer [
        <cCall: 'gstzmq_getsockopt_reconnect_ivl' returning: #int args: #(#cObject)> 
    ]

    get_socket_reconnect_ivl_max: aPointer [
        <cCall: 'gstzmq_getsockopt_reconnect_ivl_max' returning: #int args: #(#cObject)> 
    ]

    get_socket_backlog: aPointer [
        <cCall: 'gstzmq_getsockopt_backlog' returning: #int args: #(#cObject)> 
    ]

    get_socket_fd: aPointer [
        <cCall: 'gstzmq_getsockopt_fd' returning: #int args: #(#cObject)> 
    ]

    get_socket_swap: aPointer [
        <cCall: 'gstzmq_getsockopt_swap' returning: #long args: #(#cObject)> 
    ]

    get_socket_rate: aPointer [
        <cCall: 'gstzmq_getsockopt_rate' returning: #long args: #(#cObject)> 
    ]

    get_socket_recovery_ivl: aPointer [
        <cCall: 'gstzmq_getsockopt_recovery_ivl' returning: #long args: #(#cObject)> 
    ]

    get_socket_recovery_ivl_msec: aPointer [
        <cCall: 'gstzmq_getsockopt_recovery_ivl_msec' returning: #long args: #(#cObject)> 
    ]

    get_socket_mcast_loop: aPointer [
        <cCall: 'gstzmq_getsockopt_mcast_loop' returning: #long args: #(#cObject)> 
    ]

    get_socket_hwm: aPointer [
        <cCall: 'gstzmq_getsockopt_hwm' returning: #uLong args: #(#cObject)> 
    ]

    get_socket_affinity: aPointer [
        <cCall: 'gstzmq_getsockopt_affinity' returning: #uLong args: #(#cObject)> 
    ]

    get_socket_sndbuf: aPointer [
        <cCall: 'gstzmq_getsockopt_sndbuf' returning: #uLong args: #(#cObject)> 
    ]

    get_socket_rcvbuf: aPointer [
        <cCall: 'gstzmq_getsockopt_rcvbuf' returning: #uLong args: #(#cObject)> 
    ]

    get_socket_events: aPointer [
        <cCall: 'gstzmq_getsockopt_events' returning: #uLong args: #(#cObject)> 
    ]

    get_socket_identity: aPointer [
        <cCall: 'gstzmq_getsockopt_identity' returning: #stringOut args: #(#cObject)> 
    ]

    set_socket_hwm: aPointer [
        <cCall: 'gstzmq_setsockopt_hwm' returning: #int args: #(#cObject #uLong)> 
    ]

    set_socket_affinity: aPointer [
        <cCall: 'gstzmq_setsockopt_affinity' returning: #int args: #(#cObject #uLong)> 
    ]

    set_socket_sndbuf: aPointer [
        <cCall: 'gstzmq_setsockopt_sndbuf' returning: #int args: #(#cObject #uLong)> 
    ]

    set_socket_rcvbuf: aPointer [
        <cCall: 'gstzmq_setsockopt_rcvbuf' returning: #int args: #(#cObject #uLong)> 
    ]

    set_socket_swap: aPointer [
        <cCall: 'gstzmq_setsockopt_swap' returning: #int args: #(#cObject #long)> 
    ]

    set_socket_rate: aPointer [
        <cCall: 'gstzmq_setsockopt_rate' returning: #int args: #(#cObject #long)> 
    ]

    set_socket_recovery_ivl: aPointer [
        <cCall: 'gstzmq_setsockopt_recovery_ivl' returning: #int args: #(#cObject #long)> 
    ]

    set_socket_recovery_ivl_msec: aPointer [
        <cCall: 'gstzmq_setsockopt_recovery_ivl_msec' returning: #int args: #(#cObject #long)> 
    ]

    set_socket_mcast_loop: aPointer [
        <cCall: 'gstzmq_setsockopt_mcast_loop' returning: #int args: #(#cObject #long)> 
    ]

    set_socket_identity: aPointer [
        <cCall: 'gstzmq_setsockopt_identity' returning: #int args: #(#cObject #string)> 
    ]

    set_socket_subscribe: aPointer [
        <cCall: 'gstzmq_setsockopt_subscribe' returning: #int args: #(#cObject #string)> 
    ]

    set_socket_unsubscribe: aPointer [
        <cCall: 'gstzmq_setsockopt_unsubscribe' returning: #int args: #(#cObject #string)> 
    ]

    set_socket_linger: aPointer [
        <cCall: 'gstzmq_setsockopt_linger' returning: #int args: #(#cObject #int)> 
    ]

    set_socket_reconnect_ivl: aPointer [
        <cCall: 'gstzmq_setsockopt_reconnect_ivl' returning: #int args: #(#cObject #int)> 
    ]

    set_socket_reconnect_ivl_max: aPointer [
        <cCall: 'gstzmq_setsockopt_reconnect_ivl_max' returning: #int args: #(#cObject #int)> 
    ]

    set_socket_backlog: aPointer [
        <cCall: 'gstzmq_setsockopt_backlog' returning: #int args: #(#cObject #int)> 
    ]

    errno [
        <cCall: 'zmq_errno' returning: #int args: #(#void)> 
    ]

    strerror: anInt [
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
] "Class Core"

] "Namespace ZMQ"
