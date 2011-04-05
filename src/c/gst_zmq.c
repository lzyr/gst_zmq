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
gstzmq_NOBLOCK ()
{
  return ZMQ_NOBLOCK;
}

static int
strtype_to_int (const char *type)
{
  if (strcmp (type, "Request") == 0)
    return ZMQ_REQ;
  else if (strcmp (type, "Reply") == 0)
    return ZMQ_REP;
  else if (strcmp (type, "Publish") == 0)
    return ZMQ_PUB;
  else if (strcmp (type, "Subscribe") == 0)
    return ZMQ_SUB;
  else if (strcmp (type, "Push") == 0)
    return ZMQ_PUSH;
  else if (strcmp (type, "Pull") == 0)
    return ZMQ_PULL;
  return -1;
}

void *
gstzmq_socket (void *context, const char *type)
{
  return zmq_socket (context, strtype_to_int (type));
}

int
gstzmq_send_bytes (void *socket, char *str, size_t len, int flags)
{
  zmq_msg_t message;
  int r = 0;

  zmq_msg_init_data (&message, str, len, NULL, NULL);
  r = zmq_send (socket, &message, flags);
  zmq_msg_close (&message);
  return r;
}

int
gstzmq_send_string (void *socket, char *str, int flags)
{
  return gstzmq_send_bytes (socket, str, strlen (str), flags);
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

typedef struct bytes_container_
{
  size_t size;
  char *bytes;
} bytes_container;

size_t 
gstzmq_bytes_size (void *obj)
{
  bytes_container *bytes = (bytes_container *)obj;
  return bytes->size;
}

void * 
gstzmq_bytes (void *obj)
{
  bytes_container *bytes = (bytes_container *)obj;
  return bytes->bytes;
}

void 
gstzmq_bytes_free (void *obj)
{
  free (obj);
}

void *
gstzmq_recv_bytes (void *socket, int flags)
{
  zmq_msg_t message;
  int size;
  char *str;
  bytes_container *bytes;

  zmq_msg_init (&message);
  if (zmq_recv (socket, &message, flags))
    return NULL;
  size = zmq_msg_size (&message);
  str = malloc (size);
  memcpy (str, zmq_msg_data (&message), size);
  zmq_msg_close (&message);
  bytes = malloc (sizeof (bytes_container));
  bytes->size = size;
  bytes->bytes = str;
  return ((void *)bytes);
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

/* polling. */

typedef struct poll_info_
{
  size_t size;
  size_t count;
  zmq_pollitem_t *items;
} poll_info;

poll_info *
gstzmq_init_poll_info (size_t size)
{
  poll_info *pi = malloc (sizeof (poll_info));

  if (pi == NULL)
    return NULL;

  pi->size = size;
  pi->count = 0;
  pi->items = malloc (sizeof (zmq_pollitem_t) * size);

  if (pi->items == NULL)
    {
      free (pi);
      return NULL;
    }
  return pi;
}

void
gstzmq_delete_poll_info (poll_info *pi)
{
  free (pi->items);
  free (pi);
}

int
gstzmq_poll_info_add (poll_info *pi, void *socket,
                      int fd, short events, 
                      short revents)
{
  zmq_pollitem_t zpi;

  if (pi->count >= pi->size)
    return -1;

  zpi.socket = socket;
  zpi.fd = fd;
  zpi.events = events;
  zpi.revents = revents;
  pi->items[pi->count++] = zpi;
  return 0;
}

int
gstzmq_poll (poll_info *pi, long timeout)
{
  return zmq_poll (pi->items, pi->count, timeout);
}

/* get/set socket options. */

static int
get_int_sockopt (void *socket, int option_name)
{
  int opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return -2;
}

static uint32_t
get_uint32_t_sockopt (void *socket, int option_name)
{
  uint32_t opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return 0;
}

static uint64_t
get_uint64_t_sockopt (void *socket, int option_name)
{
  uint64_t opt = 0;
  size_t sz = sizeof (opt);
  int res = zmq_getsockopt (socket, option_name, (void *)&opt, (void *)&sz);
  if (res == 0)
    return opt;
  return 0;
}

static int64_t
get_int64_t_sockopt (void *socket, int option_name)
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
  return get_int_sockopt (socket, ZMQ_TYPE);
}

int
gstzmq_getsockopt_rcvmore (void *socket)
{
  return get_int_sockopt (socket, ZMQ_RCVMORE);
}

int
gstzmq_getsockopt_linger (void *socket)
{
  return get_int_sockopt (socket, ZMQ_LINGER);
}

int
gstzmq_getsockopt_reconnect_ivl (void *socket)
{
  return get_int_sockopt (socket, ZMQ_RECONNECT_IVL);
}

int
gstzmq_getsockopt_reconnect_ivl_max (void *socket)
{
  return get_int_sockopt (socket, ZMQ_RECONNECT_IVL_MAX);
}

int
gstzmq_getsockopt_backlog (void *socket)
{
  return get_int_sockopt (socket, ZMQ_BACKLOG);
}

int
gstzmq_getsockopt_fd (void *socket)
{
  return get_int_sockopt (socket, ZMQ_FD);
}

int64_t
gstzmq_getsockopt_swap (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_SWAP);
}

int64_t
gstzmq_getsockopt_rate (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_RATE);
}

int64_t
gstzmq_getsockopt_recovery_ivl (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_RECOVERY_IVL);
}

int64_t
gstzmq_getsockopt_recovery_ivl_msec (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_RECOVERY_IVL_MSEC);
}

int64_t
gstzmq_getsockopt_mcast_loop (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_MCAST_LOOP);
}

/*
int64_t
gstzmq_getsockopt_maxmsgsize (void *socket)
{
  return get_int64_t_sockopt (socket, ZMQ_MAXMSGSIZE);
}
*/

uint64_t
gstzmq_getsockopt_hwm (void *socket)
{
  return get_int_sockopt (socket, ZMQ_HWM);
}

uint64_t
gstzmq_getsockopt_affinity (void *socket)
{
  return get_uint64_t_sockopt (socket, ZMQ_AFFINITY);
}

uint64_t
gstzmq_getsockopt_sndbuf (void *socket)
{
  return get_uint64_t_sockopt (socket, ZMQ_SNDBUF);
}

uint64_t
gstzmq_getsockopt_rcvbuf (void *socket)
{
  return get_uint64_t_sockopt (socket, ZMQ_RCVBUF);
}

uint32_t
gstzmq_getsockopt_events (void *socket)
{
  return get_uint32_t_sockopt (socket, ZMQ_EVENTS);
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

static int
gstzmq_int_setsockopt (void *socket, int option_name, int option_value)
{
  int rc = zmq_setsockopt (socket, option_name, 
                           &option_value, sizeof (option_value));
  return rc;
}

static int
gstzmq_int64_t_setsockopt (void *socket, int option_name, int64_t option_value)
{
  int rc = zmq_setsockopt (socket, option_name, 
                           &option_value, sizeof (option_value));
  return rc;
}

static int
gstzmq_uint64_t_setsockopt (void *socket, int option_name, uint64_t option_value)
{
  int rc = zmq_setsockopt (socket, option_name, 
                           &option_value, sizeof (option_value));
  return rc;
}

static int
gstzmq_binary_setsockopt (void *socket, int option_name, 
                          const char *option_value, size_t len)
{
  int rc = zmq_setsockopt (socket, option_name, 
                           (const void *)option_value, 
                           len);
  return rc;
}

int
gstzmq_setsockopt_hwm (void *socket, uint64_t value)
{
  return gstzmq_uint64_t_setsockopt (socket, ZMQ_HWM, value);
}

int
gstzmq_setsockopt_affinity (void *socket, uint64_t value)
{
  return gstzmq_uint64_t_setsockopt (socket, ZMQ_AFFINITY, value);
}

int
gstzmq_setsockopt_sndbuf (void *socket, uint64_t value)
{
  return gstzmq_uint64_t_setsockopt (socket, ZMQ_SNDBUF, value);
}

int
gstzmq_setsockopt_rcvbuf (void *socket, uint64_t value)
{
  return gstzmq_uint64_t_setsockopt (socket, ZMQ_RCVBUF, value);
}

int
gstzmq_setsockopt_swap (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_SWAP, value);
}

int
gstzmq_setsockopt_rate (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_RATE, value);
}

int
gstzmq_setsockopt_recovery_ivl (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_RECOVERY_IVL, value);
}

int
gstzmq_setsockopt_recovery_ivl_msec (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_RECOVERY_IVL_MSEC, value);
}

int
gstzmq_setsockopt_mcast_loop (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_MCAST_LOOP, value);
}

/*
int
gstzmq_setsockopt_maxmsgsize (void *socket, int64_t value)
{
  return gstzmq_int64_t_setsockopt (socket, ZMQ_MAXMSGSIZE, value);
}
*/

int
gstzmq_setsockopt_identity (void *socket, const char *value)
{
  size_t len = strlen (value);
  return gstzmq_binary_setsockopt (socket, ZMQ_IDENTITY, 
                                   value, len);
}

int
gstzmq_setsockopt_subscribe (void *socket, const char *value)
{
  size_t len = strlen (value);
  return gstzmq_binary_setsockopt (socket, ZMQ_SUBSCRIBE,
                                   value, len);
}

int
gstzmq_setsockopt_unsubscribe (void *socket, const char *value)
{
  size_t len = strlen (value);
  return gstzmq_binary_setsockopt (socket, ZMQ_UNSUBSCRIBE,
                                   value, len);
}

int
gstzmq_setsockopt_linger (void *socket, int value)
{
  return gstzmq_int_setsockopt (socket, ZMQ_LINGER, value);
}

int
gstzmq_setsockopt_reconnect_ivl (void *socket, int value)
{
  return gstzmq_int_setsockopt (socket, ZMQ_RECONNECT_IVL, value);
}

int
gstzmq_setsockopt_reconnect_ivl_max (void *socket, int value)
{
  return gstzmq_int_setsockopt (socket, ZMQ_RECONNECT_IVL_MAX, value);
}

int
gstzmq_setsockopt_backlog (void *socket, int value)
{
  return gstzmq_int_setsockopt (socket, ZMQ_BACKLOG, value);
}
