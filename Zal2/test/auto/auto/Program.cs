using System.Numerics;
using System.Runtime.Serialization;
using System.Text;
using mdiv_auto;

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

void Calculate(int test)
{
    Console.Write("Test " + test + "\n");
    int n = int.Parse(readNext());
    long[] tab = new long[n];
    for (int i = 0; i < n; i++)
    {
        tab[i] = Convert.ToInt64(readNext());
    }

    long dir = Convert.ToInt64(readNext());
    if (dir == 0)
    {
        Console.WriteLine("ovf");
        return;
    }

    bool shouldResultBeNegative = false;

    if (tab[n - 1] != 0 && dir != 0)
    {
        shouldResultBeNegative = tab[n - 1] < 0 != dir < 0;
    }

    ulong divider = dir < 0 ? (ulong)-dir : (ulong)dir;

    bool shouldModBeNegative = tab[n - 1] < 0;

    ulong[] utab = Negate.ToUlongs(tab);

    long rest = 0;
    for (int i = n - 1; i >= 0; i--)
    {
        BigInteger tmp = new BigInteger(rest);
        tmp = tmp << 64;
        tmp += new BigInteger(utab[i]);
        rest = (long)(tmp % divider);
        utab[i] = (ulong)(tmp / divider);
    }

    long mod = (long)rest;

    if (shouldModBeNegative)
    {
        mod = -mod;
    }

    if (!shouldResultBeNegative && utab[^1] == 9223372036854775808)
    {
        Console.WriteLine("ovf");
        return;
    }

    long[] results = Negate.ToLongs(utab, shouldResultBeNegative);

    foreach (long a in results)
    {
        Console.WriteLine(a);
    }

    Console.WriteLine(mod);
}

int testsCount = int.Parse(readNext());
for (int test = 1; test <= testsCount; test++)
{
    Calculate(test);
}
return 0;
