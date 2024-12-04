// See https://aka.ms/new-console-template for more information

bool xmasN(char[][] field, int h, int w, int x, int y)
{
    if (y < 3)
        return false;
    return field[y - 1][x] == 'M' && field[y - 2][x] == 'A' && field[y - 3][x] == 'S';
}

bool xmasS(char[][] field, int h, int w, int x, int y)
{
    if (y >= h - 3)
        return false;
    return field[y + 1][x] == 'M' && field[y + 2][x] == 'A' && field[y + 3][x] == 'S';
}

bool xmasW(char[][] field, int h, int w, int x, int y)
{
    if (x < 3)
        return false;
    return field[y][x - 1] == 'M' && field[y][x - 2] == 'A' && field[y][x - 3] == 'S';
}

bool xmasE(char[][] field, int h, int w, int x, int y)
{
    if (x >= w - 3)
        return false;
    return field[y][x + 1] == 'M' && field[y][x + 2] == 'A' && field[y][x + 3] == 'S';
}

bool xmasNE(char[][] field, int h, int w, int x, int y)
{
    if (x >= w - 3 || y < 3)
        return false;
    return field[y - 1][x + 1] == 'M' && field[y - 2][x + 2] == 'A' && field[y - 3][x + 3] == 'S';
}

bool xmasSW(char[][] field, int h, int w, int x, int y)
{
    if (x < 3 || y >= h - 3)
        return false;
    return field[y + 1][x - 1] == 'M' && field[y + 2][x - 2] == 'A' && field[y + 3][x - 3] == 'S';
}

bool xmasSE(char[][] field, int h, int w, int x, int y)
{
    if (x >= w - 3 || y >= h - 3)
        return false;
    return field[y + 1][x + 1] == 'M' && field[y + 2][x + 2] == 'A' && field[y + 3][x + 3] == 'S';
}

bool xmasNW(char[][] field, int h, int w, int x, int y)
{
    if (x < 3 || y < 3)
        return false;
    return field[y - 1][x - 1] == 'M' && field[y - 2][x - 2] == 'A' && field[y - 3][x - 3] == 'S';
}

bool masCross(char[][] field, int h, int w, int x, int y)
{
    if (field[y][x] != 'A')
        return false;
    if (x < 1 || x >= w - 1 || y < 1 || y >= h - 1)
        return false;

    if (field[y + 1][x - 1] == 'S' && field[y + 1][x + 1] == 'S' && field[y - 1][x - 1] == 'M' && field[y - 1][x + 1] == 'M') return true;
    if (field[y + 1][x - 1] == 'S' && field[y - 1][x - 1] == 'S' && field[y + 1][x + 1] == 'M' && field[y - 1][x + 1] == 'M') return true;
    if (field[y - 1][x + 1] == 'S' && field[y - 1][x - 1] == 'S' && field[y + 1][x + 1] == 'M' && field[y + 1][x - 1] == 'M') return true;
    if (field[y - 1][x + 1] == 'S' && field[y + 1][x + 1] == 'S' && field[y - 1][x - 1] == 'M' && field[y + 1][x - 1] == 'M') return true;

    return false;
}

int hasXmas(char[][] field, int h, int w, int x, int y)
{
    if (field[y][x] != 'X')
        return 0;
    var sum = 0;
    if (xmasN(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasS(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasW(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasE(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasNE(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasSE(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasNW(field, h, w, x, y))
    {
        sum += 1;
    }
    if (xmasSW(field, h, w, x, y))
    {
        sum += 1;
    }
    return sum;
}


async Task part1(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);
    var field = text.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim().ToCharArray()).ToArray();
    var h = field.Length;
    var w = field[0].Length;
    var sum = 0;
    for (int x = 0; x < w; x++)
    {
        for (int y = 0; y < w; y++)
        {
            var s = hasXmas(field, h, w, x, y);
            if (s > 0)
            {
                //Console.WriteLine($"{x},{y} = {s}");
            }
            sum += s;
        }
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {sum}");
}

async Task part2(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);
    var field = text.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim().ToCharArray()).ToArray();
    var h = field.Length;
    var w = field[0].Length;
    var sum = 0;
    for (int x = 0; x < w; x++)
    {
        for (int y = 0; y < w; y++)
        {
            if (masCross(field, h, w, x, y))
            {

                sum += 1;
            }
        }
    }
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {sum}");
}


await part1("../../../../input/test4.txt");
await part1("../../../../input/input4.txt");
await part2("../../../../input/test4.2.txt");
await part2("../../../../input/input4.txt");
