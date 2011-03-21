/*
ZMQ API helper functions for GNU Smalltalk.
Copyright (C) 2011 by Vijay Mathew Pandyalakal<vijay.the.schemer@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include <zmq.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

int
gstzmq_REQ ()
{
  return ZMQ_REQ;
}

int
gstzmq_REP ()
{
  return ZMQ_REP;
}

int
gstzmq_send_string (void *socket, char *str, int flags)
{
  zmq_msg_t message;
  int r = 0;

  zmq_msg_init_data (&message, str, strlen (str), NULL, NULL);
  r = zmq_send (socket, &message, flags);
  zmq_msg_close (&message);
  return r;
}

char *
gstzmq_recv_string (void *socket, int flags)
{
  zmq_msg_t message;
  int size;
  char *str;

  zmq_msg_init (&message);
  if (zmq_recv (socket, &message, flags))
    return NULL;
  size = zmq_msg_size (&message);
  str = malloc (size + 1);
  memcpy (str, zmq_msg_data (&message), size);
  zmq_msg_close (&message);
  str [size] = 0;
  return (str);
}







