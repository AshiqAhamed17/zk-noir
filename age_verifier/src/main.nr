fn main(year_of_birth: u32, current_year: u32) {
    let age = current_year - year_of_birth;
    assert(age >= 18);
}

#[test]
fn  test_valid_age() {
    main(2005, 2025);
}
