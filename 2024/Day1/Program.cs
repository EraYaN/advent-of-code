// See https://aka.ms/new-console-template for more information

async Task part1(string filename) {
    var lines = await File.ReadAllLinesAsync(filename);
    List<int> list1 = [];
    List<int> list2 = [];
    foreach(var line in lines)
    {
        var parts = line.Split(' ',StringSplitOptions.RemoveEmptyEntries|StringSplitOptions.TrimEntries).Select(int.Parse).ToArray();
        list1.Add(parts[0]);
        list2.Add(parts[1]);
    }
    list1.Sort();
    list2.Sort();
    var dist = 0;
    foreach(var zipped in list1.Zip(list2))
    {
        dist += Math.Abs(zipped.First - zipped.Second);
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {dist}");
}

async Task part2(string filename)
{
    var lines = await File.ReadAllLinesAsync(filename);
    List<int> list1 = [];
    List<int> list2 = [];
    foreach (var line in lines)
    {
        var parts = line.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(int.Parse).ToArray();
        list1.Add(parts[0]);
        list2.Add(parts[1]);
    }
    list1.Sort();
    var sym = 0;
    foreach (var item in list1)
    {
        sym += item * list2.Count(s => s == item);
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {sym}");
}


await part1("../../../../input/test1.txt");
await part1("../../../../input/input1.txt");
await part2("../../../../input/test1.txt");
await part2("../../../../input/input1.txt");
