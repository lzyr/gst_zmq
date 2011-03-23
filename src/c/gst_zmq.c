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
#include <stdint.h>

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

char *
gstzmq_version ()
{
  int major = 0;
  int minor = 0;
  int patch = 0;
  char *buffer = malloc (20);

  zmq_version (&major, &minor, &patch);
  sprintf (buffer, "%d.%d.%d", major, minor, patch);
  return buffer; // Freed in Smalltalk.
}

/* get/set socket options. */

static int
get_int_socketopt (void *socket, int option_name)
{
  int opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return -2;
}

static uint32_t
get_uint32_t_socketopt (void *socket, int option_name)
{
  uint32_t opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return 0;
}

static uint64_t
get_uint64_t_socketopt (void *socket, int option_name)
{
  uint64_t opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return 0;
}

static int64_t
get_int64_t_socketopt (void *socket, int option_name)
{
  int64_t opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return -2;
}

int
gstzmq_getsockopt_type (void *socket)
{
  return get_int_socketopt (socket, ZMQ_TYPE);
}

int
gstzmq_getsockopt_rcvmore (void *socket)
{
  return get_int_socketopt (socket, ZMQ_RCVMORE);
}

int
gstzmq_getsockopt_linger (void *socket)
{
  return get_int_socketopt (socket, ZMQ_LINGER);
}

int
gstzmq_getsockopt_reconnect_ivl (void *socket)
{
  return get_int_socketopt (socket, ZMQ_RECONNECT_IVL);
}

int
gstzmq_getsockopt_reconnect_ivl_max (void *socket)
{
  return get_int_socketopt (socket, ZMQ_RECONNECT_IVL_MAX);
}

int
gstzmq_getsockopt_backlog (void *socket)
{
  return get_int_socketopt (socket, ZMQ_BACKLOG);
}

int
gstzmq_getsockopt_fd (void *socket)
{
  return get_int_socketopt (socket, ZMQ_FD);
}

int64_t
gstzmq_getsockopt_swap (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_SWAP);
}

int64_t
gstzmq_getsockopt_rate (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_RATE);
}

int64_t
gstzmq_getsockopt_recovery_ivl (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_RECOVERY_IVL);
}

int64_t
gstzmq_getsockopt_recovery_ivl_msec (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_RECOVERY_IVL_MSEC);
}

int64_t
gstzmq_getsockopt_mcast_loop (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_MCAST_LOOP);
}

/*
int64_t
gstzmq_getsockopt_maxmsgsize (void *socket)
{
  return get_int64_t_socketopt (socket, ZMQ_MAXMSGSIZE);
}
*/

uint64_t
gstzmq_getsockopt_hwm (void *socket)
{
  return get_int_socketopt (socket, ZMQ_HWM);
}

uint64_t
gstzmq_getsockopt_affinity (void *socket)
{
  return get_uint64_t_socketopt (socket, ZMQ_AFFINITY);
}

uint64_t
gstzmq_getsockopt_sndbuf (void *socket)
{
  return get_uint64_t_socketopt (socket, ZMQ_SNDBUF);
}

uint64_t
gstzmq_getsockopt_rcvbuf (void *socket)
{
  return get_uint64_t_socketopt (socket, ZMQ_RCVBUF);
}

uint32_t
gstzmq_getsockopt_events (void *socket)
{
  return get_uint32_t_socketopt (socket, ZMQ_EVENTS);
}

char *
gstzmq_getsockopt_identity (void *socket)
{
  char opt[255];
  size_t sz = 255;
  int res = zmq_getsockopt (socket, ZMQ_IDENTITY, (void *)&opt, (void *)&sz);
  if (res == 0)
    {
      char *identity = malloc (sz + 1);
      opt[sz] = 0;
      strcpy (identity, opt);
      return identity; // freed in Smalltalk.
    }
  return NULL;
}

