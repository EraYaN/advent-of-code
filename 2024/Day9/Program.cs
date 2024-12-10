// See https://aka.ms/new-console-template for more information

using System.Diagnostics;

using Fs = System.Collections.Generic.LinkedList<Block>;
using Node = System.Collections.Generic.LinkedListNode<Block>;

async Task part1(string filename)
{
    var text = (await File.ReadAllTextAsync(filename)).Trim();

    var grid = new FileSystem(text);

    //grid.SetAntinodes();
    //grid.Print();

    grid.Consolidate(true);

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {grid.Checksum()}");
}



async Task part2(string filename)
{
    var text = (await File.ReadAllTextAsync(filename)).Trim();

    var grid = new FileSystem(text);

    //grid.SetAntinodes();
    //grid.Print();

    grid.Consolidate(false);

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {grid.Checksum()}");
}


await part1("../../../../input/test9.txt");

await part1("../../../../input/input9.txt");
//////
await part2("../../../../input/test9.txt");
await part2("../../../../input/input9.txt");

record struct Block(int fileId, int length) { }

class FileSystem
{
    public Fs fs;

    public FileSystem(string dense)
    {
        fs = new Fs(dense.Select((ch, i) => new Block(i % 2 == 1 ? -1 : i / 2, ch - '0')));
    }

    public void Print()
    {
        Console.Write("FS: ");
        for (var i = fs.First; i != null; i = i.Next)
        {
            if (i.Value.fileId == -1)
            {
                for(int j = 0; j < i.Value.length; j++)
                {
                    Console.Write('.');
                }
            }
            else
            {
                for (int j = 0; j < i.Value.length; j++)
                {
                    Console.Write(i.Value.fileId % 10);
                }
            }
        }
        Console.WriteLine();
    }

    public void Consolidate(bool fragmentsEnabled)
    {
        var (i, j) = (fs.First, fs.Last);
        while (i != j)
        {
            if (i.Value.fileId != -1)
            {
                i = i.Next;
            }
            else if (j.Value.fileId == -1)
            {
                j = j.Previous;
            }
            else
            {
                RelocateBlock(i, j, fragmentsEnabled);
                j = j.Previous;
            }
            //Print();
        }
    }

    // Relocates the contents of block `j` to a free space starting after the given node `start`. 
    // - Searches for the first suitable free block after `start`.
    // - If a block of equal size is found, `j` is moved entirely to that block.
    // - If a larger block is found, part of it is used for `j`, and the remainder is split into 
    //   a new free block.
    // - If a smaller block is found and fragmentation is enabled, a portion of `j` is moved to fit, 
    //   leaving the remainder in place.
    void RelocateBlock(Node start, Node j, bool fragmentsEnabled)
    {
        for (var i = start; i != j; i = i.Next)
        {
            if (i.Value.fileId != -1)
            {
                // noop
            }
            else if (i.Value.length == j.Value.length)
            {
                (i.Value, j.Value) = (j.Value, i.Value);
                return;
            }
            else if (i.Value.length > j.Value.length)
            {
                var d = i.Value.length - j.Value.length;
                i.Value = j.Value;
                j.Value = j.Value with { fileId = -1 };
                fs.AddAfter(i, new Block(-1, d));
                return;
            }
            else if (i.Value.length < j.Value.length && fragmentsEnabled)
            {
                var d = j.Value.length - i.Value.length;
                i.Value = i.Value with { fileId = j.Value.fileId };
                j.Value = j.Value with { length = d };
                fs.AddAfter(j, new Block(-1, i.Value.length));
            }
        }
    }

    public long Checksum()
    {
        var res = 0L;
        var l = 0;
        for (var i = fs.First; i != null; i = i.Next)
        {
            for (var k = 0; k < i.Value.length; k++)
            {
                if (i.Value.fileId != -1)
                {
                    res += l * i.Value.fileId;
                }
                l++;
            }
        }
        return res;
    }
}

