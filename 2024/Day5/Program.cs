// See https://aka.ms/new-console-template for more information


List<Ordering> parseOrderings(string[] items){
    List<Ordering> l = [];

    foreach(var item in items){
        l.Add(new Ordering(item));
    }
    return l;
}

List<int[]> parseUpdates(string[] items){
    List<int[]> l = [];

    foreach(var item in items){
        l.Add(item.Split(",", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray());
    }
    return l;
}

bool isCorrectlyOrdered(int[] update, List<Ordering> ord){
    for(int i=0;i<update.Length; i++){
        var item = update[i];
        var shouldNotBeBelow = ord.Where(o => o.lower == item).Select(o=>o.upper).ToList();
        var shouldNotBeAbove = ord.Where(o => o.upper == item).Select(o=>o.lower).ToList();
        
        foreach(var upper in shouldNotBeAbove){
            if(update[(i+1)..].Contains(upper)){
                return false;
            }
        }
        foreach(var lower in shouldNotBeBelow){
            if(update[..(i)].Contains(lower)){
                return false;
            }
        }
    }
    return true;
}

List<Ordering> orderings = new List<Ordering>();

async Task part1(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);
    int emptyIndex = text.Select(s => s.Trim()).TakeWhile(t => t!=string.Empty).Count();

    orderings = parseOrderings(text[..emptyIndex]);

    var updates = parseUpdates(text[(emptyIndex+1)..]);
    var sum= 0;
    foreach(var update in updates){
        if(isCorrectlyOrdered(update, orderings)){
            sum+= update[update.Length >> 1];
        }
    }

    Console.WriteLine(updates[0][0]);
   
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 1: {sum}");
}



async Task part2(string filename)
{
    var text = await File.ReadAllLinesAsync(filename);
    int emptyIndex = text.Select(s => s.Trim()).TakeWhile(t => t!=string.Empty).Count();

    orderings = parseOrderings(text[..emptyIndex]);

    var updates = parseUpdates(text[(emptyIndex+1)..]);
    var sum= 0;
    foreach(var update in updates){
        if(!isCorrectlyOrdered(update, orderings)){
            //Console.WriteLine(string.Join(',', update));
            Array.Sort(update,ComparePages);
            sum+= update[update.Length >> 1];
        }
    }

    Console.WriteLine(updates[0][0]);
    Console.WriteLine($"{Path.GetFileName(filename)}: Part 2: {sum}");
}

int ComparePages(int s1, int s2)
{
    if(s1 == s2){
        return 0;
    }
    if(orderings.Where(o => o.lower == s1).Select(o=>o.upper).Contains(s2)){
        return -1;
    }
    if(orderings.Where(o => o.upper == s1).Select(o=>o.lower).Contains(s2)){
        return 1;
    }
    return 0;
}

await part1("../input/test5.txt");
await part1("../input/input5.txt");
//

await part2("../input/test5.txt");
await part2("../input/input5.txt");


struct Ordering{
    public int lower;
    public int upper;

    public Ordering(string s){
        var arr = s.Trim().Split("|", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();
        if(arr.Length != 2){
            throw new ArgumentException(nameof(s),"Invalid ordering");
        }
        this.lower = arr[0];
        this.upper = arr[1];
    }
}

