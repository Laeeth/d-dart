import core.memory;
import std.c.stdlib;
import std.stdio;
import dart_api;
import dart_native_api;
import d_sample_callee;

void wrappedRandomArray(Dart_Port dest_port_id,Dart_Port reply_port_id,Dart_CObject* message)
{
  //foolish foo;
  //writefln("%s",cast(long)foo.value.fool);
  if ((message.type == Dart_CObject_Type.Dart_CObject_kArray) &&((*message.value.as_array.slength)==2))
  {
    // Use .as_array and .as_int32 to access the data in the Dart_CObject.
    Dart_CObject* param0 = message.value.as_array.values[0];
    Dart_CObject* param1 = message.value.as_array.values[1];
    if ((param0.type == Dart_CObject_Type.Dart_CObject_kInt32) && (param1.type == Dart_CObject_Type.Dart_CObject_kInt32))
    {
      int mylength = param0.value.as_int32;
      int seed = param1.value.as_int32;
      ubyte* values = random_array(seed, mylength);

      if (values) {
        Dart_CObject result;
        result.type = Dart_CObject_Type.Dart_CObject_kArray;  // should be Uint8Array
        result.value.as_array.values = cast(_Dart_CObject**) values;           // was as_byte_array
        *result.value.as_array.slength = mylength;        // was as_byte_array
        Dart_PostCObject(reply_port_id, &result);
        free(cast(void*)values);
        // It is OK that result is destroyed when function exits.
        // Dart_PostCObject has copied its data.
        return;
      }
    }
  }
  Dart_CObject result;
  result.type = Dart_CObject_Type.Dart_CObject_kNull;
  Dart_PostCObject(reply_port_id, &result);
}

void randomArrayServicePort(Dart_NativeArguments arguments) {
  Dart_SetReturnValue(arguments, Dart_Null());
  Dart_Port service_port =Dart_NewNativePort("RandomArrayService", cast(Dart_NativeMessageHandler)&wrappedRandomArray, true);
  if (service_port != ILLEGAL_PORT) {
    Dart_Handle send_port = Dart_NewSendPort(service_port);
    Dart_SetReturnValue(arguments, send_port);
  }
}