/*
 * Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 *
 * Hacked on by Laeeth Isharc (2014) to port API to D lang.  Use at your own risk.
 */

 
/*
 * ==========================================
 * Message sending/receiving from native code
 * ==========================================
 */

/**
 * A Dart_CObject is used for representing Dart objects as native C
 * data outside the Dart heap. These objects are totally detached from
 * the Dart heap. Only a subset of the Dart objects have a
 * representation as a Dart_CObject.
 *
 * The string encoding in the 'value.as_string' is UTF-8.
 *
 * All the different types from dart:typed_data are exposed as type
 * kTypedData. The specific type from dart:typed_data is in the type
 * field of the as_typed_data structure. The length in the
 * as_typed_data structure is always in bytes.
 */

import dart_api;

enum Dart_CObject_Type {
  Dart_CObject_kNull = 0,
  Dart_CObject_kBool,
  Dart_CObject_kInt32,
  Dart_CObject_kInt64,
  Dart_CObject_kBigint,
  Dart_CObject_kDouble,
  Dart_CObject_kString,
  Dart_CObject_kArray,
  Dart_CObject_kTypedData,
  Dart_CObject_kExternalTypedData,
  Dart_CObject_kSendPort,
  Dart_CObject_kUnsupported,
  Dart_CObject_kNumberOfTypes
}

struct _as_bigint {
  bool neg;
  intptr_t used;
  _Dart_CObject* digits;
}
struct _as_array {
  intptr_t length;
  _Dart_CObject** values;
}

struct _as_typed_data {
  Dart_TypedData_Type type;
  intptr_t length;
  uint8_t* values;
}

struct _as_external_typed_data {
  Dart_TypedData_Type type;
  intptr_t length;
  uint8_t* data;
  void* peer;
  Dart_WeakPersistentHandleFinalizer callback;
}

struct _Dart_CObject {
  Dart_CObject_Type type;
  union value {
    bool as_bool;
    int32_t as_int32;
    int64_t as_int64;
    double as_double;
    char* as_string;
    _as_bigint as_bigint;
    Dart_Port as_send_port;
    _as_array as_array;
    _as_typed_data as_typed_data;
    _as_external_typed_data as_external_typed_data;
  }
}

alias Dart_CObject=_Dart_CObject;

/**
 * Posts a message on some port. The message will contain the
 * Dart_CObject object graph rooted in 'message'.
 *
 * While the message is being sent the state of the graph of
 * Dart_CObject structures rooted in 'message' should not be accessed,
 * as the message generation will make temporary modifications to the
 * data. When the message has been sent the graph will be fully
 * restored.
 *
 * \param port_id The destination port.
 * \param message The message to send.
 *
 * \return True if the message was posted.
 */
extern(C) bool Dart_PostCObject(Dart_Port port_id, Dart_CObject* message);

/**
 * A native message handler.
 *
 * This handler is associated with a native port by calling
 * Dart_NewNativePort.
 *
 * The message received is decoded into the message structure. The
 * lifetime of the message data is controlled by the caller. All the
 * data references from the message are allocated by the caller and
 * will be reclaimed when returning to it.
 */

extern (C) alias Dart_NativeMessageHandler = void function(Dart_Port dest_port_id,Dart_CObject* message);

/**
 * Creates a new native port.  When messages are received on this
 * native port, then they will be dispatched to the provided native
 * message handler.
 *
 * \param name The name of this port in debugging messages.
 * \param handler The C handler to run when messages arrive on the port.
 * \param handle_concurrently Is it okay to process requests on this
 *                            native port concurrently?
 *
 * \return If successful, returns the port id for the native port.  In
 *   case of error, returns ILLEGAL_PORT.
 */
extern (C)  Dart_Port Dart_NewNativePort(const char* name,Dart_NativeMessageHandler handler,bool handle_concurrently);
/* TODO(turnidge): Currently handle_concurrently is ignored. */

/**
 * Closes the native port with the given id.
 *
 * The port must have been allocated by a call to Dart_NewNativePort.
 *
 * \param native_port_id The id of the native port to close.
 *
 * \return Returns true if the port was closed successfully.
 */
extern (C) bool Dart_CloseNativePort(Dart_Port native_port_id);


/*
 * ==================
 * Verification Tools
 * ==================
 */

/**
 * Forces all loaded classes and functions to be compiled eagerly in
 * the current isolate..
 *
 * TODO(turnidge): Document.
 */
extern (C) Dart_Handle Dart_CompileAll();
