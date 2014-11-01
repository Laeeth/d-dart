import std.c.stdlib;
import std.c.string;
import std.stdio;
import dart_api;

// Forward declaration of ResolveName function.
Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope);

//extern (C) Dart_Handle Dart_SetNativeResolver(Dart_Handle library,Dart_NativeEntryResolver resolver,Dart_NativeEntrySymbol symbol);

// The name of the initialization function is the extension name followed
// by _Init.
extern (C) Dart_Handle sample_extension_Init(Dart_Handle parent_library)
{
  if (Dart_IsError(parent_library)) return parent_library;

  Dart_Handle result_code =Dart_SetNativeResolver(parent_library, cast(Dart_NativeEntryResolver)&ResolveName,cast(Dart_NativeEntrySymbol) 0);
  if (Dart_IsError(result_code)) return result_code;

  return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
 if (Dart_IsError(handle)) Dart_PropagateError(handle);
 return handle;
}

// Native functions get their arguments in a Dart_NativeArguments structure
// and return their results with Dart_SetReturnValue.
extern (C) void SystemRand(Dart_NativeArguments arguments) {
  Dart_Handle result = HandleError(Dart_NewInteger(rand()));
  Dart_SetReturnValue(arguments, result);
}

extern(C) void SystemSrand(Dart_NativeArguments arguments) {
  bool success = false;
  Dart_Handle seed_object =
      HandleError(Dart_GetNativeArgument(arguments, 0));
  if (Dart_IsInteger(seed_object)) {
    bool fits;
    HandleError(Dart_IntegerFitsIntoInt64(seed_object, &fits));
    if (fits) {
      long seed;
      HandleError(Dart_IntegerToInt64(seed_object, &seed));
      srand(cast(uint)(seed));
      success = true;
    }
  }
  Dart_SetReturnValue(arguments, HandleError(Dart_NewBoolean(success)));
}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope) {
  // If we fail, we return NULL, and Dart throws an exception.
  if (!Dart_IsString(name)) return cast(Dart_NativeFunction)0;
  Dart_NativeFunction result = cast(Dart_NativeFunction)0;
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  if (strcmp("SystemRand", cname) == 0) result = &SystemRand;
  if (strcmp("SystemSrand", cname) == 0) result = &SystemSrand;
  return result;
}