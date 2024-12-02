// See https://aka.ms/new-console-template for more information

bool IsSafe(List<int> list, int? skip = null)
{
    if (list.Count < 2)
    {
        return true;
    }
    
    if (skip is int s)
    {
        list = [.. list];
        list.RemoveAt(s);
    }    

    bool is_ascending = list[0] < list[1];
    for (int i = 0; i < list.Count - 1; i++)
    {
        int diff = list[i + 1] - list[i];
        if (is_ascending && (diff < 1 || diff > 3))
        {
            return false;
        }
        else
        if (!is_ascending && (diff > -1 || diff < -3))
        {
            return false;
        }
    }
    return true;
}

bool IsSafeDampened(List<int> list)
{
    for (int i = 0; i < list.Count; i++)
    {
        if (IsSafe(list, i))
        {
            //Console.WriteLine($"Is safe with list[{i}] = {list[i]} removed");
            return true;
        }
    }
    return false;
}

async Task part1(string filename)
{
    var lines = await File.ReadAllLinesAsync(filename);
    List<int> list1 = [];
    List<int> list2 = [];
    int safe_count = 0;
    foreach (var line in lines)
    {
        var parts = line.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(int.Parse).ToList();
        if (IsSafe(parts)) safe_count++;
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {safe_count}");
}

async Task part2(string filename)
{
    var lines = await File.ReadAllLinesAsync(filename);
    List<int> list1 = [];
    List<int> list2 = [];
    int safe_count = 0;
    foreach (var line in lines)
    {
        var parts = line.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(int.Parse).ToList();
        if (IsSafe(parts))
        {
            //Console.WriteLine($"{line} is safe with no removal");
            safe_count++;
            continue;
        }
        //Console.WriteLine($"Checking {line} for dampened safety");
        if (IsSafeDampened(parts))
        {
            safe_count++;
        }
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {safe_count}");
}


await part1("../../../../input/test2.txt");
await part1("../../../../input/input2.txt");
await part2("../../../../input/test2.txt");
await part2("../../../../input/input2.txt");
