// See https://aka.ms/new-console-template for more information

async Task part1(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    var grid = new Grid(text);
    int i = 0;
    while (grid.Iteration()>0)
    {
        //Console.WriteLine($"After iteration: {i++}");
        //grid.Print();
    }

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {grid.Count()}");
}



async Task part2(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    var grid = new Grid(text);
    int h = grid.h;
    int w = grid.w;
    int count =    0;
    for (int y = 0; y < h; y++)
    {
        Console.WriteLine($"Processing line {y}");
        for (int x = 0; x < w; x++)
        {
            Console.WriteLine($"Extra obstruction at {x},{y}");
            grid = new Grid(text, (x,y));
            int i = 0;
            while (true)
            {
                int o = grid.Iteration(true);
                if (o == 0)
                {
                    break;
                }
                if (o == -1)
                {
                    //Console.WriteLine($"Extra obstruction at {x},{y} made loop");
                    //grid.Print();
                    count++;
                    break;
                }
                //Console.WriteLine($"After iteration: {i++}");
                //grid.Print();
            }


        }
    }
        

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {count}");
}


await part1("../../../../input/test6.txt");

await part1("../../../../input/input6.txt");
//

await part2("../../../../input/test6.txt");
await part2("../../../../input/input6.txt");


internal class Grid
{
    public char[][] field;
    public int[] visited;
    public int h, w;
    public (int,int) guard;

    public Grid(string[] lines, (int, int)? extra = null)
    {
        field = lines.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim().ToCharArray()).ToArray();
        h = field.Length;
        w = field[0].Length;
        visited = new int[h * w];

        if(extra != null)
        {
            field[extra.Value.Item2][extra.Value.Item1] = 'O';
        }
    }

    public (int, int) FindGuard()
    {
        var c = Get(guard);
        if(c != '#' && c != 'O' && c != '.')
        {
            return guard;
        }
        for (int x = 0; x < w; x++)
        {
            for (int y = 0; y < h; y++)
            {
                if (field[y][x] != '#' && field[y][x] != 'O' && field[y][x] != '.')
                {
                    guard = (x, y);
                    return guard;
                }
            }
        }
        return (-1, -1);
    }

    private void UpdateGuard((int,int) pos)
    {
        var c = Get(pos);
        if (c != '#' && c != 'O' && c != '.')
        {
            guard = pos;
        }
    }

    public void Print((int, int)? markedpos = null)
    {
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                var pos = (x, y);
                if (markedpos != null && markedpos == pos)
                {
                    Console.Write('M');
                }
                else
                {
                    var c = Get(pos);
                    if (c == '.' && GetMark(pos) > 0)
                    {
                        Console.Write('X');
                    }
                    else
                    {
                        Console.Write(c);
                    }
                }
            }
            Console.WriteLine();
        }
    }

    private char Get((int, int) pos)
    {
        return field[pos.Item2][pos.Item1];
    }

    private int GetMark((int, int) pos)
    {
        return visited[pos.Item2 * w + pos.Item1];
    }

    private void Mark((int, int) pos)
    {
        visited[pos.Item2 * w + pos.Item1]++;
    }

    public int Count()
    {
        return visited.Count(v => v > 0);
    }

    private bool IsOutsideBounds((int, int) pos)
    {
        return pos.Item1 < 0 || pos.Item1 >= w || pos.Item2 < 0 || pos.Item2 >= h;
    }

    public int Iteration(bool detectLoop = false)
    {
        var pos = FindGuard();
        if (pos == (-1, -1))
        {
            return 0;
        }

        char c = Get(pos);

        if (c == '>')
        {
            var newpos = (pos.Item1 + 1, pos.Item2);
            //Console.WriteLine("Grid >:");
            //Print(newpos);
            if (IsOutsideBounds(newpos))
            {
                return 0;
            }
            var newc = Get(newpos);
            Mark(pos);
            if (newc == '#' || newc == 'O')
            {
                field[pos.Item2][pos.Item1] = 'v';
            }
            else
            {
                if (GetMark(newpos) > 5 && detectLoop)
                {
                    return -1;
                }
                Mark(newpos);
                field[newpos.Item2][newpos.Item1] = '>';
                field[pos.Item2][pos.Item1] = '.';
                UpdateGuard(newpos);
            }
        }
        else if (c == '<')
        {
            var newpos = (pos.Item1 - 1, pos.Item2);
            //Console.WriteLine("Grid <:");
            //Print(newpos);
            if (IsOutsideBounds(newpos))
            {
                return 0;
            }
            var newc = Get(newpos);

            Mark(pos);
            if (newc == '#' || newc == 'O')
            {
                field[pos.Item2][pos.Item1] = '^';
            }
            else
            {
                if (GetMark(newpos) > 5 && detectLoop)
                {
                    return -1;
                }
                Mark(newpos);
                field[newpos.Item2][newpos.Item1] = '<';
                field[pos.Item2][pos.Item1] = '.';
                UpdateGuard(newpos);
            }
        }
        else if (c == '^')
        {
            var newpos = (pos.Item1, pos.Item2 - 1);
           // Console.WriteLine("Grid ^:");
           // Print(newpos);
            if (IsOutsideBounds(newpos))
            {
                return 0;
            }
            var newc = Get(newpos);
            Mark(pos);
            if (newc == '#' || newc == 'O')
            {
                field[pos.Item2][pos.Item1] = '>';
            }
            else
            {
                if (GetMark(newpos) > 5 && detectLoop)
                {
                    return -1;
                }
                Mark(newpos);
                field[newpos.Item2][newpos.Item1] = '^';
                field[pos.Item2][pos.Item1] = '.';
                UpdateGuard(newpos);
            }
        }
        else if (c == 'v')
        {
            var newpos = (pos.Item1, pos.Item2 + 1);
            //Console.WriteLine("Grid v:");
            //Print(newpos);
            if (IsOutsideBounds(newpos))
            {
                return 0;
            }
            var newc = Get(newpos);
            Mark(pos);
            if (newc == '#' || newc == 'O')
            {
                field[pos.Item2][pos.Item1] = '<';
            }
            else
            {
                if (GetMark(newpos) > 5 && detectLoop)
                {
                    return -1;
                }
                Mark(newpos);
                field[newpos.Item2][newpos.Item1] = 'v';
                field[pos.Item2][pos.Item1] = '.';
                UpdateGuard(newpos);
            }
        }
        return 1;
    }
}

