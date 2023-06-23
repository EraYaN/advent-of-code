pub mod pair;
pub mod range;

use crate::pair::Pair;
use utils;

fn main() {
    let mut total_contained = 0;
    let mut total_overlap = 0;
    if let Ok(lines) = utils::read_lines("./input.txt") {
        // Consumes the iterator, returns an (Optional) String
        // let mut group_idx = 0;
        // let mut group : Vec<String> = vec![];
        for line in lines {
            if let Ok(pair) = line {
                let p = Pair::from_line(&pair);
                if p.is_contained() {
                    total_contained+=1
                }
                if p.is_overlapped() {
                    total_overlap+=1
                }
            }
        }
    }
    println!("Total Contained: {}", total_contained);
    println!("Total Overlap: {}", total_overlap);
}

