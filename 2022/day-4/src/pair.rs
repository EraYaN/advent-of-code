use crate::range::Range;

pub struct Pair {
    elf1: Range,
    elf2: Range,
}

impl Pair {
    pub fn from_line(line: &str) -> Self {
        let elves : Vec<&str> = line.split(",").collect();
        Self { elf1:Range::from_line(elves[0]), elf2: Range::from_line(elves[1]) }
    }

    pub fn new(a: u32, b: u32, c:u32, d:u32) -> Self {
        Self { elf1:Range::new(a,b), elf2:Range::new(c,d) }
    }

    pub fn is_contained(&self) -> bool {
        self.elf1.is_contained(&self.elf2) || self.elf2.is_contained(&self.elf1)
    }

    pub fn is_overlapped(&self) -> bool {
        self.elf1.overlap(&self.elf2) > 0
    }
}
