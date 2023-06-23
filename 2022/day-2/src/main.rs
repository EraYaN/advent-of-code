use utils;

const SCORE_ROCK: i32 = 1;
const SCORE_PAPER: i32 = 2;
const SCORE_SCISSORS: i32 = 3;

const SCORE_LOSS: i32 = 0;
const SCORE_DRAW: i32 = 3;
const SCORE_WIN: i32 = 6;

const INPUT_ROCK: char = 'A';
const INPUT_PAPER: char = 'B';
const INPUT_SCISSORS: char = 'C';

const OUTPUT_ROCK: char = 'X';
const OUTPUT_PAPER: char = 'Y';
const OUTPUT_SCISSORS: char = 'Z';

const OUTPUT_LOSS: char = 'X';
const OUTPUT_DRAW: char = 'Y';
const OUTPUT_WIN: char = 'Z';

enum RPS {
    Rock,
    Paper,
    Scissors
}

enum Outcome {
    Win,
    Draw,
    Loss
}

fn get_enum(a : char) -> RPS {
    match a {
        INPUT_ROCK | OUTPUT_ROCK => return RPS::Rock,
        INPUT_PAPER | OUTPUT_PAPER => return RPS::Paper,
        INPUT_SCISSORS | OUTPUT_SCISSORS => return RPS::Scissors,
        _ => panic!("Unsupported input or output found '{}'",a)
    }
}

fn get_outcome_enum(a : char) -> Outcome {
    match a {
        OUTPUT_LOSS =>  Outcome::Loss,
        OUTPUT_DRAW =>  Outcome::Draw,
        OUTPUT_WIN =>  Outcome::Win,
        _ => panic!("Unsupported output found '{}'",a)
    }
}

fn get_hand_score(a: &RPS) -> i32 {
    match a {
        RPS::Rock =>  SCORE_ROCK,
        RPS::Paper =>  SCORE_PAPER,
        RPS::Scissors =>  SCORE_SCISSORS,
    }
}

fn get_outcome_score(them : &RPS, you: &RPS) -> i32 {
    match (them, you) {
        (RPS::Rock, RPS::Rock) =>  SCORE_DRAW,
        (RPS::Rock, RPS::Paper) =>  SCORE_WIN,
        (RPS::Rock, RPS::Scissors) =>  SCORE_LOSS,
        (RPS::Paper, RPS::Rock) =>  SCORE_LOSS,
        (RPS::Paper, RPS::Paper) =>  SCORE_DRAW,
        (RPS::Paper, RPS::Scissors) =>  SCORE_WIN,
        (RPS::Scissors, RPS::Rock) =>  SCORE_WIN,
        (RPS::Scissors, RPS::Paper) =>  SCORE_LOSS,
        (RPS::Scissors, RPS::Scissors) =>  SCORE_DRAW,
    }
}

fn get_round_score(them : &RPS, you: &RPS) -> i32 {
    return get_outcome_score(them, you) + get_hand_score(you)
}

fn get_required_hand(them : &RPS, you: &Outcome) -> RPS {
    match (them, you) {
        (RPS::Rock, Outcome::Win) => RPS::Paper,
        (RPS::Rock, Outcome::Draw) => RPS::Rock,
        (RPS::Rock, Outcome::Loss) => RPS::Scissors,
        (RPS::Paper, Outcome::Win) => RPS::Scissors,
        (RPS::Paper, Outcome::Draw) => RPS::Paper,
        (RPS::Paper, Outcome::Loss) => RPS::Rock,
        (RPS::Scissors, Outcome::Win) => RPS::Rock,
        (RPS::Scissors, Outcome::Draw) => RPS::Scissors,
        (RPS::Scissors, Outcome::Loss) => RPS::Paper,
    }
}

fn main() {
    

    let mut score = 0;

    let mut score_part2 = 0;

    // File hosts.txt must exist in the current path
    if let Ok(lines) = utils::read_lines("./input.txt") {
        // Consumes the iterator, returns an (Optional) String
        for line in lines {
            if let Ok(round) = line {
                if round.len() == 3 {
                    let mut round_chars = round.chars();
                    let input = round_chars.next().unwrap();
                    round_chars.next();
                    let output = round_chars.next().unwrap();
                    score += get_round_score(&get_enum(input), &get_enum(output));
                    let required_hand = get_required_hand(&get_enum(input), &get_outcome_enum(output));
                    score_part2 += get_round_score(&get_enum(input), &required_hand);
                }
            }
        }
    }

    
    println!("Part 1 (score): {}", score);
    println!("Part 2 (score): {}", score_part2);
}
