const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const testInput =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

pub fn main() !void {
    const partOneAnswer = try partOne(checkDifference);
    //const partTwoAnswer = try solver(checkDifferenceWithDampner);

    print("Answer for Part One:\n\tValid Reports: {d}\n", .{partOneAnswer});
    //print("Answer for Part Two:\n\tValid Reports: {d}\n", .{partTwoAnswer});
}

fn partOne(differenceFunc: fn ([]usize) bool) !usize {
    var lines = tokenizeSeq(u8, data, "\n");
    var validCounter: usize = 0;

    while (lines.next()) |line| {
        var chars = tokenizeSeq(u8, line, " ");
        var array = List(usize).init(gpa);
        defer array.deinit();

        while (chars.next()) |char| {
            try array.append(try parseInt(usize, char, 10));
        }

        const arrSortedAsc = try gpa.dupe(usize, array.items);
        const arrSortedDesc = try gpa.dupe(usize, array.items);
        defer gpa.free(arrSortedAsc);
        defer gpa.free(arrSortedDesc);

        sort(usize, arrSortedAsc, {}, comptime asc(usize));
        sort(usize, arrSortedDesc, {}, comptime desc(usize));

        if (std.mem.eql(usize, array.items, arrSortedAsc)) {
            if (differenceFunc(array.items))
                validCounter += 1;
        } else if (std.mem.eql(usize, array.items, arrSortedDesc)) {
            if (differenceFunc(array.items))
                validCounter += 1;
        } else {
            continue;
        }
    }

    return validCounter;
}

fn checkDifference(list: []usize) bool {
    var passed = true;
    for (list, 0..) |curr, idx| {
        if (list.len == idx + 1) break;

        const next = list[idx + 1];
        const diff = if (curr > next) curr - next else next - curr;

        if (diff < 1 or diff > 3) {
            passed = false;
            break;
        }
    }
    return passed;
}

fn checkDifferenceWithDampner(list: []usize) bool {
    var dampedLevels: usize = 0;
    for (list, 0..) |curr, idx| {
        if (list.len == idx + 1) break;

        const next = list[idx + 1];
        const diff = if (curr > next) curr - next else next - curr;

        if (diff < 1 or diff > 3) {
            dampedLevels += 1;
        }
    }

    std.debug.print("Damped Levels: {d}\n", .{dampedLevels});
    return if (dampedLevels <= 1) true else false;
}
// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
