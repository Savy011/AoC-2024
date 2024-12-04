const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

const testInput = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

pub fn main() !void {
    const answerPartOne = try partOne(data);

    print("Answer for Part One:\n\tResult of Multiplications: {d}", .{answerPartOne});
}

fn partOne(input: []const u8) !usize {
    var res: usize = 0;

    var lines = tokenizeSeq(u8, input, "\n");

    while (lines.next()) |line| {
        var matches = try regex_at_home(gpa, "mul($,$)", line);
        defer matches.deinit();

        for (matches.items) |num| {
            var numbers = tokenizeSca(u8, num[4 .. num.len - 1], ',');

            const numOne = try parseInt(usize, numbers.next().?, 10);
            const numTwo = try parseInt(usize, numbers.next().?, 10);

            res += numOne * numTwo;
        }
    }

    return res;
}

test "Part One" {
    try std.testing.expectEqual(161, try partOne(testInput));
}

const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;

const parseInt = std.fmt.parseInt;

const print = std.debug.print;

// Stolen from https://github.com/joinemm/advent-of-code-2024/blob/master/src/03/solution.zig
fn regex_at_home(alloc: std.mem.Allocator, find: []const u8, input: []const u8) !std.ArrayList([]u8) {
    var next_char: usize = 0;
    var number_mode = false;
    var matches = std.ArrayList([]u8).init(alloc);
    var match = std.ArrayList(u8).init(alloc);
    defer match.deinit();

    var i: usize = 0;
    while (i < input.len) {
        const ch = input[i];
        i += 1;

        if (find[next_char] == '$') {
            // number mode
            number_mode = true;
            if (std.ascii.isDigit(ch)) {
                try match.append(ch);
            } else {
                next_char += 1;
                number_mode = false;
            }
        } else {
            number_mode = false;
        }

        if (!number_mode) {
            // match ascii
            if (ch == find[next_char]) {
                try match.append(ch);
                next_char += 1;
            } else {
                // reset
                if (match.items.len != 0) {
                    i -= 1;
                    match.clearRetainingCapacity();
                    next_char = 0;
                }
            }
        }

        if (next_char == find.len) {
            // complete match, save and reset
            try matches.append(try alloc.dupe(u8, match.items));
            match.clearRetainingCapacity();
            next_char = 0;
        }
    }

    return matches;
}
