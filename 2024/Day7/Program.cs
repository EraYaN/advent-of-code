// See https://aka.ms/new-console-template for more information

using System.ComponentModel.Design.Serialization;
using System.Security.Cryptography;

async Task part1(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    long sum = 0;
    foreach (var line in text)
    {
        var eq = new Equation(line);
        if (eq.Solve() > 0)
        {
            sum += eq.Result;
        }
    }

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {sum}");
}



async Task part2(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    long sum = 0;
    foreach (var line in text)
    {
        var eq = new Equation(line);
        if (eq.Solve(true) > 0)
        {
            sum += eq.Result;
        }
    }

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {sum}");
}


await part1("../../../../input/test7.txt");
await part1("../../../../input/input7.txt");
//

await part2("../../../../input/test7.txt");
await part2("../../../../input/input7.txt");

class Equation
{
    readonly char[] opChars = [ '+', '*' ];
    readonly char[] opChars2 = [ '+', '*','|' ];
    long[] numbers;
    long result;
    char[] operators;
    long numOperators => numbers.Length - 1;

    public long Result => result;

    public Equation(string line)
    {
        var parts = line.Split(':', StringSplitOptions.TrimEntries);
        result = long.Parse(parts[0]);

        numbers = parts[1].Split(' ').Select(long.Parse).ToArray();
        operators = new char[numbers.Length - 1];
    }

    public void Prlong()
    {
        Console.Write(result);
        Console.Write(" = ");
        for (long i = 0; i < numbers.Length; i++)
        {
            Console.Write(numbers[i]);
            if (i < operators.Length)
            {
                Console.Write(operators[i]);
            }
        }
        if (IsValid())
        {
            Console.WriteLine(" v");
        } else
        {
            Console.WriteLine($" x ({Value()})");
        }
    }

    private bool IsValid()
    {
        return Value() == result;
    }

    private long Value()
    {
        long calc = numbers[0];

        for(long i= 0; i < operators.Length; i++)
        {
            switch (operators[i])
            {
                case '+':
                    calc += numbers[i + 1];
                    break;
                case '*':
                    calc *= numbers[i + 1];
                    break;
                case '|':
                    calc = long.Parse($"{calc}{numbers[i + 1]}");
                    break;
            }
        }
        return calc;
    }

    public long Solve(bool part2 = false)
    {
        long valid = 0;
        foreach(var perm in Permutations.CombinationsWithRepetition(part2?opChars2:opChars, numOperators))
        {
            //Console.WriteLine($"Permutation {string.Join(',', perm)}");
            operators = perm;
            //Prlong();
            if (IsValid())
            {
                valid++;
            }
        }
        return valid;
    }
}


public static class Permutations
{
    public static IEnumerable<char[]> NextPermutation(char[] elements, long count)
    {
        return null; // elements.SelectMany(v => elements, (s,v) => [s,v]);

    }

    public static IEnumerable<IEnumerable<T>> DifferentCombinations<T>(this IEnumerable<T> elements, long k)
    {
        return k == 0 ? [Array.Empty<T>()] :
          elements.SelectMany((e, i) =>
            elements.Skip(i + 1).DifferentCombinations(k - 1).Select(c => (new[] { e }).Concat(c)));
    }

    public static IEnumerable<char[]> CombinationsWithRepetition(IEnumerable<char> input, long length)
    {
        if (length <= 0)
            yield return Array.Empty<char>();
        else
        {
            foreach (var i in input)
                foreach (var c in CombinationsWithRepetition(input, length - 1))
                    yield return [i, .. c];
        }
    }
}

