using System.Numerics;
using System.Runtime.Serialization;
using System.Text;

char[] END_CHARS = { ' ', '\n', '\r', '\t' };

string readNext()
{
  StringBuilder sb = new StringBuilder();
  char c;
  do
  {
    c = (char)Console.Read();
    if (END_CHARS.Contains(c))
      break;
    sb.Append(c);
  } while (true);
  return sb.ToString();
}

long GetRandom(Random random)
{
  return (long)(random.NextDouble() * long.MaxValue * (random.Next(0, 2) == 0 ? 1 : -1));
}

ulong testsCount = ulong.Parse(readNext());
long minN = long.Parse(readNext());
long maxN = long.Parse(readNext());

Console.WriteLine(testsCount);
Random random = new Random();

for (ulong test = 1; test <= testsCount; test++)
{
  long n = random.NextInt64(minN, maxN);
  Console.Write(n + " ");
  for (long i = 0; i < n; i++)
  {
    long segment = GetRandom(random);
    Console.Write(segment + " ");
  }
  long divider = GetRandom(random);
  Console.WriteLine(divider);
}