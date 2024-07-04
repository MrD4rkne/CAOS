namespace mdiv_auto;

public static class Negate
{
    public static ulong[] ToUlongs(long[] tab)
    {
        if (tab[^1] > 0)
        {
            ulong[] utab1 = new ulong[tab.Length];
            for (int i = 0; i < tab.Length; i++)
            {
                utab1[i] = (ulong)tab[i];
            }

            return utab1;
        }
    
        ulong[] unsignedTab = new ulong[tab.Length];
        for (int i = 0; i < tab.Length; i++)
        {
            tab[i] ^= -1;
            unsignedTab[i] = (ulong)tab[i];
        }

        bool wasCarry = true;
        int c = 0;
        while (wasCarry && c < tab.Length)
        {
            wasCarry = unsignedTab[c] == ulong.MaxValue;
            unchecked
            {
                unsignedTab[c] += 1;
            }
            c++;
        }

        return unsignedTab;
    }
    
    public static long[] ToLongs(ulong[] tab, bool shouldBeNegative)
    {
        if (!shouldBeNegative)
        {
            long[] ltab = new long[tab.Length];
            for (int i = 0; i < tab.Length; i++)
            {
                ltab[i] = (long)tab[i];
            }

            return ltab;
        }
    
        long[] signedTab = new long[tab.Length];
        for (int i = 0; i < tab.Length; i++)
        {
            tab[i] ^= ulong.MaxValue;
            signedTab[i] = (long)tab[i];
        }

        bool wasCarry = true;
        int c = 0;
        while (wasCarry && c < tab.Length)
        {
            wasCarry = signedTab[c] == long.MaxValue;
            unchecked
            {
                signedTab[c] += 1;
            }
            c++;
        }

        return signedTab;
    }
}