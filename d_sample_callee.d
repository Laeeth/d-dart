import core.memory;
import std.c.stdlib; // probably a better D way, but I am lazy and want to keep close to the sample code

ubyte* random_array(int seed, int mylength)
{
  if (mylength <= 0 || mylength > 10000000)
  	return cast(ubyte*) 0;

  ubyte* values = cast(ubyte*)(malloc(mylength));
  if (!values)
  	return cast(ubyte*) 0;

  srand(seed);
  foreach(i;0..mylength)
  {
    values[i] = cast(ubyte)(rand() % 256);
  }
  return values;
}