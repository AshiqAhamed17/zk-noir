fn main(age: i16, min_age: pub i16) {
    assert(age >= min_age);
}

#[test]
fn test_main() {
    main(19, 18);

    // Uncomment to make test fail
    // main(1, 1);
}
