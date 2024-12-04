// See https://aka.ms/new-console-template for more information


using System.Text.RegularExpressions;

async Task part1(string filename)
{
    var text = await File.ReadAllTextAsync(filename);
    var matches = Regex.Matches(text, @"mul\((\d+),(\d+)\)");
    var sum = 0;
    foreach (var match in matches)
    {
        if (match is Match m) { 
            var a = int.Parse(m.Groups[1].Value);
            var b = int.Parse(m.Groups[2].Value);
            sum += a * b;
            Console.WriteLine($"{a} * {b} = {a * b}");
        }
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {sum}");
}

async Task part2(string filename)
{
    var text = await File.ReadAllTextAsync(filename);
    var matches = Regex.Matches(text, @"(do(n't)?\(\))|(mul\((\d+),(\d+)\))");
    var sum = 0;
    var enabled = true;
    foreach (var match in matches)
    {
        if (match is Match m)
        {
            if (m.Groups[0].Value == "do()")
            {
                enabled = true;
            }else if (m.Groups[0].Value == "don't()")
            {
                enabled = false;
            }
            else if (enabled)
            {
                var a = int.Parse(m.Groups[4].Value);
                var b = int.Parse(m.Groups[5].Value);
                sum += a * b;
                Console.WriteLine($"{a} * {b} = {a * b}");
            }
        }
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {sum}");
}


await part1("../../../../input/test3.txt");
await part1("../../../../input/input3.txt");
await part2("../../../../input/test3.2.txt");
await part2("../../../../input/input3.txt");
