const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try part_one_and_two(allocator);
}

pub fn part_one_and_two(allocator: std.mem.Allocator) !void {
    var part1Sum: u64 = 0;
    var part2Sum: u64 = 0;

    var doubledVals = std.ArrayList(u64).init(allocator);
    var currVal: u64 = 1;
    try doubledVals.insert(doubledVals.items.len, currVal);
    for (0..24) |idx| {
        _ = idx;
        currVal *= 2;
        try doubledVals.insert(doubledVals.items.len, currVal);
    }
    const numLines = 6;
    var lines = std.mem.split(u8, input, "\r\n");
    var lineNum: u16 = 0;

    var p2Carries = std.ArrayList(u16).init(allocator);
    try p2Carries.appendNTimes(0, numLines + 1);

    while (lines.next()) |line| {
        lineNum += 1;
        var desc = std.mem.split(u8, line, ":");
        var card = desc.first();
        _ = card;
        var nums = desc.next().?;
        var nums_split = std.mem.split(u8, nums, "|");
        var winners = nums_split.first();
        var ours = nums_split.next().?;
        //print("{s} | {s}\n", .{ winners, ours });
        var hashMap = std.AutoHashMap(u16, void).init(allocator);
        var winner_splits = std.mem.split(u8, winners, " ");
        while (winner_splits.next()) |winner| {
            if (winner.len > 0) {
                try hashMap.put(try std.fmt.parseInt(u16, winner, 10), {});
            }
        }
        var numWinners: u16 = 0;
        var ours_split = std.mem.split(u8, ours, " ");
        while (ours_split.next()) |ourNum| {
            if (ourNum.len > 0) {
                if (hashMap.contains(try std.fmt.parseInt(u16, ourNum, 10))) {
                    numWinners += 1;
                }
            }
        }
        if (numWinners > 0) {
            part1Sum += (doubledVals.items[numWinners - 1]);
        }
        part2Sum += 1;
        part2Sum += p2Carries.items[lineNum - 1];
        print("print2Sum: {d}\n", .{part2Sum});
        for (0..numWinners) |offset| {
            p2Carries.items[lineNum - 1 + offset + 1] += 1;
        }
    }
    print("Answer for Day 4 part 1 is: {d}\n", .{part1Sum});
    print("Answer for Day 4 part 2 is: {d}\n", .{part2Sum});
    for (p2Carries.items[1..], 1..) |item, idx| {
        print("{d}: {d}\n", .{ idx + 1, item });
    }
}
