// See https://aka.ms/new-console-template for more information

using System.Diagnostics;

async Task part1(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    var grid = new Grid(text);

    grid.SetAntinodes();
    //grid.Print();

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {grid.Count()}");
}



async Task part2(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);

    var grid = new Grid(text);

    grid.SetAntinodesWithHarmonics();
    // grid.Print();

    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {grid.Count()}");
}


await part1("../../../../input/test8.txt");

await part1("../../../../input/input8.txt");
////

await part2("../../../../input/test8.txt");
await part2("../../../../input/input8.txt");


[DebuggerDisplay("Point({x}, {y})")]
record struct Point
{
    public int x, y;
    public Point(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public double DistanceTo(Point other)
    {
        return this.DistanceTo(other.x, other.y);
    }

    public double DistanceTo(int x, int y)
    {
        return Math.Sqrt(Math.Pow(this.x + x, 2) + Math.Pow(this.y + y, 2));
    }

    public Point MirrorBy(Point other)
    {
        int d_x = other.x - x;
        int d_y = other.y - y;
        return new Point(x + 2 * (d_x), y + 2 * (d_y));
    }

    public List<Point> GetMirrors(Point other, int w, int h)
    {
        var current = new Point(this.x, this.y);
        var points = new List<Point>();
        while (true)
        {
            var p = current.MirrorBy(other);
            if (p.x < 0 || p.x >= w || p.y < 0 || p.y >= h)
            {
                break;
            }
            points.Add(p);
            current = other;
            other = p;
        }
        return points;
    }
}

[DebuggerDisplay("Antenna({freq}, {p})")]
struct Antenna
{
    public char freq;
    public Point p;

    public Antenna(char freq, Point p)
    {
        this.freq = freq;
        this.p = p;
    }
}

[DebuggerDisplay("Pair({a1}, {a2}, {distance})")]
struct Pair
{
    public Antenna a1, a2;
    public double distance;

    public Pair(Antenna a1, Antenna a2)
    {
        this.a1 = a1;
        this.a2 = a2;
        distance = a1.p.DistanceTo(a2.p);
    }
}

class Grid
{
    public char[][] field;
    public int[] antinodes;
    public int h, w;

    public List<Antenna> antennas = [];
    public List<Pair> pairs = [];

    public Grid(string[] lines, Point? extra = null)
    {
        field = lines.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim().ToCharArray()).ToArray();
        h = field.Length;
        w = field[0].Length;
        antinodes = new int[h * w];

        if (extra != null)
        {
            field[extra.Value.x][extra.Value.y] = 'O';
        }

        SetAntenna();
        SetPairs();
    }

    private void SetAntenna()
    {
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                var p = new Point(x, y);
                var c = Get(p);
                if (c != '.' && c != '#')
                {
                    antennas.Add(new Antenna(c, p));
                }
            }
        }
    }
    static IEnumerable<IEnumerable<T>> GetPermutations<T>(IEnumerable<T> items, int count)
    {
        int i = 0;
        foreach (var item in items)
        {
            if (count == 1)
                yield return new T[] { item };
            else
            {
                foreach (var result in GetPermutations(items.Skip(i + 1), count - 1))
                    yield return new T[] { item }.Concat(result);
            }

            ++i;
        }
    }

    private void SetPairs()
    {
        var groups = antennas.GroupBy(a => a.freq);
        foreach (var group in groups)
        {
            var list = group.ToList();
            foreach (var pair in GetPermutations(list, 2))
            {
                var a = pair.ToArray();
                pairs.Add(new Pair(a[0], a[1]));
            }
        }
    }

    public void SetAntinodesWithHarmonics()
    {
        foreach (var pair in pairs)
        {
            SetAntinode(pair.a1.p);
            SetAntinode(pair.a2.p);
            var points = pair.a1.p.GetMirrors(pair.a2.p, w, h);
            points.AddRange(pair.a2.p.GetMirrors(pair.a1.p, w, h));

            foreach (var p in points)
            {
                if (!IsOutsideBounds(p))
                {
                    SetAntinode(p);
                }
            }
        }
    }

    public void SetAntinodes()
    {
        foreach (var pair in pairs)
        {
            var p1 = pair.a1.p.MirrorBy(pair.a2.p);
            var p2 = pair.a2.p.MirrorBy(pair.a1.p);
            //Print(p1, p2);
            if (!IsOutsideBounds(p1))
            {
                SetAntinode(p1);
            }
            if (!IsOutsideBounds(p2))
            {
                SetAntinode(p2);
            }
        }
    }

    public void Print(Point? markedpos = null, Point? markedpos2 = null)
    {
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                var pos = new Point(x, y);
                if ((markedpos != null && markedpos.Value == pos) || (markedpos2 != null && markedpos2.Value == pos))
                {
                    Console.Write('M');
                }
                else
                {
                    var c = Get(pos);
                    if (c == '.' && GetAntinode(pos) > 0)
                    {
                        Console.Write('#');
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

    private char Get(Point pos)
    {
        return field[pos.y][pos.x];
    }

    private int GetAntinode(Point pos)
    {
        return antinodes[pos.y * w + pos.x];
    }

    private void SetAntinode(Point pos)
    {
        antinodes[pos.y * w + pos.x]++;
    }

    public int Count()
    {
        return antinodes.Count(v => v > 0);
    }

    private bool IsOutsideBounds(Point pos)
    {
        return pos.x < 0 || pos.x >= w || pos.y < 0 || pos.y >= h;
    }

    public int PoProrces(bool detectLoop = false)
    {

        return 1;
    }
}

