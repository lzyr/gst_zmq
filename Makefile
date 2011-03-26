CC = gcc
C_SRC = ./src/c
TARGET = /usr/local/lib
BIN = ./bin

all: mkbin libgstzmq.so

libgstzmq.so: gst_zmq.o
	${CC} -shared -Wl,-soname,libgstzmq.so -o ${BIN}/libgstzmq.so.1.0.0 ${BIN}/gst_zmq.o

gst_zmq.o: 
	${CC} -fPIC -c -Wall -o ${BIN}/gst_zmq.o ${C_SRC}/gst_zmq.c

clean:
	rm -rf ${BIN}

install:
	cp ${BIN}/libgstzmq.so.1.0.0 ${TARGET}
	/sbin/ldconfig

uninstall:
	rm -f ${TARGET}/libgstzmq.so.1.0.0
	/sbin/ldconfig

mkbin:
	mkdir -p ${BIN}