use utils;

fn split_rucksack(input: &str) -> (&str, &str) {
    let len = input.len();
    if len % 2 == 0 {
        return (&input[..len/2], &input[len/2..]);
    } else {
        panic!("String not of even length ({})...", len);
    }
}

fn get_common<'a>(r1: &'a str, r2: &'a str) -> char {
    for c in r1.chars() {
        if r2.contains(c) {
            return c
        }
    }
    return '\0'
}

fn get_common3<'a>(r1: &'a str, r2: &'a str, r3: &'a str) -> char {
    for c in r1.chars() {
        if r2.contains(c) && r3.contains(c) {
            return c
        }
    }
    return '\0'
}

fn get_priority(input: char) -> u32 {
    match input {
        'a'..='z' => (input as u32) - ('a' as u32) + 1,
        'A'..='Z' => (input as u32) - ('A' as u32) + 27,
        _ => 0,
    }
}


fn main() {
    let mut prio_sum = 0;
    let mut group_prio_sum = 0;
    if let Ok(lines) = utils::read_lines("./input.txt") {
        // Consumes the iterator, returns an (Optional) String
        let mut group_idx = 0;
        let mut group : Vec<String> = vec![];
        for line in lines {
            if let Ok(rucksack) = line {
                group.push(rucksack.clone());
                let (r1, r2) = split_rucksack(&rucksack);
                let common = get_common(r1, r2);
                println!("{},{} -> {}",r1,r2,common);
                prio_sum += get_priority(common);
                group_idx += 1;
                if group_idx >= 3{
                    let group_common = get_common3(&group[0], &group[1], &group[2]);
                    println!("Group Bagde: {}",group_common);
                    group_prio_sum += get_priority(group_common);
                    group_idx = 0;
                    group.clear();
                    println!("----");
                }
            }
            
        }
    }
    println!("Sum Prio: {}",prio_sum);
    println!("Group Sum Prio: {}",group_prio_sum);
}
