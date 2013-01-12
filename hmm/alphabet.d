#!/usr/bin/rdmd
module hmm.alphabet;

import std.stdio;

enum Type { sparse , zero_range }

template def(Type type = Type.sparse, Char = char, Value = int)
{
  static if (type == Type.sparse)
    {
      alias Map = Value[Char];

      pure auto key(Char c)
        { return c; }

      struct Alphabet
      { }

      auto make_map(in Alphabet alphabet)
        { return Map.init; }
    }
  else static if (type == Type.zero_range)
    {
      alias Map = Value[];

      pure int key(Char c)
      { return cast(int)(c); }

      struct Alphabet
      { Char size; }

      auto make_map(in Alphabet alphabet)
        { Map map; map.length = alphabet.size; return map; }
    }
}

auto count_freq(Type type, Char)(Char[] input, def!type.Alphabet alphabet = def!type.Alphabet())
{
  alias Table = def!type.Map;
  alias key   = def!type.key;
  alias make  = def!type.make_map;

  auto freq_table = make(alphabet);
  foreach (c ; input)
    ++freq_table[key(c)];
  return freq_table;
}

auto count_freq(Type type, Char, Args...)(Char[] input, Args args)
{
  return count_freq!(type,Char)(input,def!type.Alphabet(args));
}

unittest
{
  auto freq_table = count_freq!(Type.sparse)("hello world!");

  assert(freq_table.length == char.max);
  assert(freq_table[def!char.key('a')] == 0);
  assert(freq_table[def!char.key('l')] == 3);
  assert(freq_table[def!char.key('d')] == 1);
}

unittest
{
  auto freq_table = count_freq!(Type.zero_range)("hello world!",char.max);

  assert(freq_table.length == char.max);
  assert(freq_table[def!char.key('a')] == 0);
  assert(freq_table[def!char.key('l')] == 3);
  assert(freq_table[def!char.key('d')] == 1);
}

void main()
{
  auto freq_table = count_freq!(Type.zero_range)("hello world!",char.max);
  foreach (k , v ; freq_table)
    writefln("%s - %s",k,v);
}
