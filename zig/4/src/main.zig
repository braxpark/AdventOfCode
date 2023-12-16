const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try part_one_and_two(allocator);
}

pub fn part_one_and_two(allocator: std.mem.Allocator) !void {
    var part1Sum: u64 = 0;
    var part2Sum: u64 = 0;
    _ = part2Sum;

    var doubledVals = std.ArrayList(u64).init(allocator);
    var currVal: u64 = 1;
    try doubledVals.insert(doubledVals.items.len, currVal);
    for (0..24) |idx| {
        _ = idx;
        currVal *= 2;
        try doubledVals.insert(doubledVals.items.len, currVal);
    }
    const numLines = 198;
    var lines = std.mem.split(u8, input, "\r\n");
    var lineNum: u16 = 0;

    var p2Carries = std.ArrayList(u16).init(allocator);
    try p2Carries.appendNTimes(1, numLines);

    var cardWinners = std.ArrayList(u16).init(allocator);
    try cardWinners.appendNTimes(0, numLines);
    while (lines.next()) |line| {
        lineNum += 1;
        var desc = std.mem.split(u8, line, ":");
        _ = desc.first();
        var nums = desc.next().?;
        var nums_split = std.mem.split(u8, nums, "|");
        var winners = nums_split.first();
        var ours = nums_split.next().?;
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
        cardWinners.items[lineNum - 1] = numWinners;
    }

    var resultCards = std.ArrayList(u64).init(allocator);
    try resultCards.appendNTimes(1, numLines);
    var finalPart2Sum: u64 = 0;
    for (resultCards.items[0..numLines], 0..) |card, i| {
        finalPart2Sum += card;
        for (0..cardWinners.items[i], 0..) |_, j| {
            var pos = i + 1 + j;
            if (pos == numLines) {
                continue;
            } else if (pos < numLines) {
                resultCards.items[pos] += card;
            }
        }
    }
    print("Answer for Day 4 part 1 is: {d}\n", .{part1Sum});
    print("Answer for Day 4 part 2 is: {d}\n", .{finalPart2Sum});
}
