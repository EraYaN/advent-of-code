use std::cmp::{min, max};

pub struct Range {
    min: u32,
    max: u32,
}

impl Range {
    pub fn from_line(line: &str) -> Self {
        let elf : Vec<&str> = line.split("-").collect();
        Range::new(u32::from_str_radix(elf[0], 10).unwrap(), u32::from_str_radix(elf[1], 10).unwrap())
    }

    pub fn new(a: u32, b: u32) -> Self {
        Self { min: min(a,b), max: max(a,b) }
    }

    pub fn size(&self) -> u32 {
        self.max - self.min + 1
    }

    pub fn is_contained(&self, other: &Self) -> bool {
        self.min <= other.min && self.max >= other.max
    }

    pub fn is_before(&self, other: &Self) -> bool {
        self.max < other.min
    }

    pub fn overlap(&self, other: &Self) -> u32 {
        if self.is_before(other) || other.is_before(self) {
            // disjoint
            // 12....
            // ...45.
            return 0;
        } else if self.is_contained(other) || other.is_contained(self) {
            // contained
            // 123456
            // ..34..
            return min(self.size(), other.size()); // contained
        } else if self.max > other.max && other.min < self.min {
            //partial
            // 1234..
            // ..3456
            return other.max - self.min + 1
        } else {
            //partial reversed
            // ..3456
            // 1234..
            return self.max - other.min + 1
        }
    }
}

#[cfg(test)]
mod range_tests {
    use crate::range::Range;

    #[test]
    fn size() {
        let result = Range::new(1,2);
        assert_eq!(result.size(), 2);
    }

    #[test]
    fn size_neg() {
        let result = Range::new(5,1);
        assert_eq!(result.size(), 5);
    }

    #[test]
    fn overlap_partial() {
        let r1 = Range::new(1,4);
        let r2 = Range::new(3,6);
        assert_eq!(r1.overlap(&r2), 2);
        assert_eq!(r1.overlap(&r2), r2.overlap(&r1));
    }

    #[test]
    fn overlap_contained() {
        let r1 = Range::new(1,8);
        let r2 = Range::new(3,6);
        assert_eq!(r1.overlap(&r2), r2.size());
        assert_eq!(r1.overlap(&r2), r2.overlap(&r1));
    }

    #[test]
    fn overlap_match() {
        let r1 = Range::new(1,8);
        let r2 = Range::new(1,8);
        assert_eq!(r1.overlap(&r2), r2.size());
        assert_eq!(r2.overlap(&r1), r1.size());
        //assert_eq!(r1.overlap(&r2), r2.overlap(&r1));
    }

    #[test]
    fn overlap_none() {
        let r1 = Range::new(3,6);
        let r2 = Range::new(0,1);
        assert_eq!(r1.overlap(&r2), 0);
        assert_eq!(r1.overlap(&r2), r2.overlap(&r1));
    }
}