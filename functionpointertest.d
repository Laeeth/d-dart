import std.stdio;
// test_typedef.d

//typedef void (*Dart_MessageNotifyCallback)(Dart_Isolate dest_isolate);

extern(C) alias Callback=  void function(int);

extern(C) void testfn(int i)
{
	writefln("%s",i+1);
	return;
}

extern(C) void testfn2(int i)
{
	writefln("%s",i*i);
	return;
}

void foo(Callback callback)
//void foo(void function(int) callback)
{
	callback(100);
	//callback(101);
}

void main()
{
	foo(&testfn);
	foo(&testfn2);
}