use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    let mut elves: Vec<i32> = vec!(0);
    let mut idx = 0;

    // File hosts.txt must exist in the current path
    if let Ok(lines) = read_lines("./input.txt") {
        // Consumes the iterator, returns an (Optional) String
        for line in lines {
            if let Ok(calories) = line {
                if calories == "" {
                    idx+=1;
                    elves.push(0);
                } else {
                    elves[idx] += calories.parse::<i32>().unwrap();
                }
            }
        }
    }

    use std::cmp::Reverse;
    elves.sort_by_key(|w| Reverse(*w));

    println!("Part 1 (max): {}",elves.first().unwrap());

    let top3 : Vec<i32> = elves.iter().take(3).map(|x| *x).collect();
    println!("{:#?}",top3);
    let top3_sum: i32 = top3.iter().sum();
    println!("Part 2 (max top3): {}", top3_sum);
}


// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
