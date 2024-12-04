const std = @import("std");
const file = std.fs.cwd().readFile("data/day01.txt", 2000);
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var ListOne = List(usize).init(gpa);
    var ListTwo = List(usize).init(gpa);
    defer ListOne.deinit();
    defer ListTwo.deinit();

    try process(&ListOne, &ListTwo);

    const answerPartOne = try partOne(&ListOne, &ListTwo);
    const answerPartTwo = try partTwo(&ListOne, &ListTwo);

    print("Answer for Part One:\n\tDistance = {!d}\n", .{answerPartOne});
    print("Answer for Part Two:\n\tSimilarity Score = {!d}\n", .{answerPartTwo});
}

fn process(ListOne: *List(usize), ListTwo: *List(usize)) !void {
    var lines = splitSeq(u8, data, "\n");

    while (lines.next()) |line| {
        var idArr = splitSeq(u8, line, " ");

        const first = idArr.first();

        if (std.mem.eql(u8, first, "")) continue;

        const asIntFirst = try parseInt(usize, first, 10);
        try ListOne.append(asIntFirst);

        while (idArr.next()) |num| {
            if (std.mem.eql(u8, num, "")) continue;

            if (!std.mem.eql(u8, first, num)) {
                try ListTwo.append(try parseInt(usize, num, 10));
            }
        }
    }
}

fn partOne(ListOne: *List(usize), ListTwo: *List(usize)) !usize {
    var distance: usize = 0;

    const sortedListOne = try gpa.dupe(usize, ListOne.items);
    const sortedListTwo = try gpa.dupe(usize, ListTwo.items);
    defer gpa.free(sortedListOne);
    defer gpa.free(sortedListTwo);

    sort(usize, sortedListOne, {}, comptime asc(usize));
    sort(usize, sortedListTwo, {}, comptime asc(usize));

    for (sortedListOne, sortedListTwo) |a, b| {
        const d = if (a > b) a - b else b - a;
        distance += d;
    }

    return distance;
}

fn partTwo(ListOne: *List(usize), ListTwo: *List(usize)) !usize {
    var similarityScore: usize = 0;

    for (ListOne.items) |idOne| {
        var counter: usize = 0;
        for (ListTwo.items) |idTwo| {
            if (idOne == idTwo) counter += 1;
        }

        similarityScore += counter * idOne;
    }

    return similarityScore;
}

const testInput =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

test "part 1" {
    var ListOne = List(usize).init(std.testing.allocator);
    var ListTwo = List(usize).init(std.testing.allocator);
    defer ListOne.deinit();
    defer ListTwo.deinit();

    try process(&ListOne, &ListTwo);

    const answerPartOne = try partOne(&ListOne, &ListTwo);
    const answerPartTwo = try partTwo(&ListOne, &ListTwo);

    try expect(answerPartOne == 11);
    try expect(answerPartTwo == 31);
}
const splitSeq = std.mem.splitSequence;
const parseInt = std.fmt.parseInt;

const print = std.debug.print;

const expect = std.testing.expect;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;
