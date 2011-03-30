point := Point new: 100 y: 200.
byteStream := (String new) readWriteStream.
objDumper := ObjectDumper on: byteStream.
objDumper dump: point.
byteStream reset.
socket := ZMQ.Socket bind: 'tcp://*:5555'.
(socket receive) printNl.
socket sendBytes: (byteStream contents).
socket close.
