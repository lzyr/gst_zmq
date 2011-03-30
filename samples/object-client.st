socket := ZMQ.Socket connect: 'tcp://localhost:5555'.
socket send: 'getPoint'.
bytes := socket receiveBytes.
stream := bytes readWriteStream.
stream reset.
od := ObjectDumper on: stream.
point := od load.
('point=',(point x) asString, ':', (point y) asString) printNl.
socket close.
