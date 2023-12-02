const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try part_one(allocator);
    try part_two(allocator);
}

pub fn part_one(allocator: std.mem.Allocator) !void {
    var answer: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var nums = std.ArrayList(u8).init(allocator);
        var nums_size: u8 = 0;
        for (line) |byte| {
            if (byte > 47 and byte < 58) {
                try nums.insert(nums_size, byte - 48);
                nums_size += 1;
            }
        }
        if (nums.capacity > 0) {
            var first: u32 = nums.items[0];
            first *= 10;
            answer += (first + nums.getLast());
        }
    }
    std.debug.print("Sum for day 1 part 1 is: {d}\n", .{answer});
}

pub fn part_two(allocator: std.mem.Allocator) !void {
    var answer: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var nums = std.ArrayList(u8).init(allocator);
        var mp = std.StringHashMap(u8).init(allocator);
        _ = try mp.fetchPut("one", 1);
        _ = try mp.fetchPut("two", 2);
        _ = try mp.fetchPut("three", 3);
        _ = try mp.fetchPut("four", 4);
        _ = try mp.fetchPut("five", 5);
        _ = try mp.fetchPut("six", 6);
        _ = try mp.fetchPut("seven", 7);
        _ = try mp.fetchPut("eight", 8);
        _ = try mp.fetchPut("nine", 9);

        var nums_size: u32 = 0;
        for (line, 0..) |byte, index| {
            if (byte > 47 and byte < 58) {
                try nums.insert(nums_size, byte - 48);
                nums_size += 1;
            } else if (byte > 96 and byte < 123) {
                var remaining_chars = line.len - index;
                var consider_three: bool = false;
                var consider_four: bool = false;
                var consider_five: bool = false;
                if (remaining_chars > 2) {
                    consider_three = true;
                    if (remaining_chars > 3) {
                        consider_four = true;
                        if (remaining_chars > 4) {
                            consider_five = true;
                        }
                    }
                }
                if (consider_three) {
                    var next_three_len = line[index .. index + 3];
                    if (mp.contains(next_three_len)) {
                        try nums.insert(nums_size, mp.get(next_three_len) orelse 0);
                        nums_size += 1;
                    }
                }
                if (consider_four) {
                    var next_four_len = line[index .. index + 4];
                    if (mp.contains(next_four_len)) {
                        try nums.insert(nums_size, mp.get(next_four_len) orelse 0);
                        nums_size += 1;
                    }
                }
                if (consider_five) {
                    var next_five_len = line[index .. index + 5];
                    if (mp.contains(next_five_len)) {
                        try nums.insert(nums_size, mp.get(next_five_len) orelse 0);
                        nums_size += 1;
                    }
                }
            }
        }
        if (nums.capacity > 0) {
            var first: u32 = (nums.items[0] * 10);
            var last = nums.getLast();
            answer += (first + last);
        }
    }
    std.debug.print("Sum for dat 1 part 2 is: {d}\n", .{answer});
}
