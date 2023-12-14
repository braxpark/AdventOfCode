const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try part_one(allocator);
}

pub fn part_one(allocator: std.mem.Allocator) !void {
    var temp = std.mem.split(u8, input, "\r\n");
    var line_len = temp.first().len;
    var lines = std.mem.split(u8, input, "\r\n");
    var symbols = "!@#$%^&*/?-+=_";
    var line_num: u32 = 0;
    var sym_list = std.ArrayList(u32).init(allocator);
    var sym_mirror = std.ArrayList(u32).init(allocator);
    while (lines.next()) |line| {
        line_num += 1;
        for (0..line.len) |idx| {
            var ch = line[idx .. idx + 1];
            if (std.mem.containsAtLeast(u8, symbols, 1, ch)) {
                var adj_val: u32 = @intCast((line_len * (line_num - 1)) + idx);
                try sym_list.insert(sym_list.items.len, (adj_val));
                try sym_mirror.insert(sym_mirror.items.len, (line[idx]));
            }
        }
    }

    for (sym_list.items) |sym| {
        print("Symbol located at: {d}\n", .{sym});
    }

    lines = std.mem.split(u8, input, "\r\n");
    var lineNum: u16 = 0;

    var sum: u64 = 0;
    var part2Sum: u64 = 0;
    var gears = std.AutoArrayHashMap(usize, std.ArrayList(usize)).init(allocator);

    while (lines.next()) |line| {
        lineNum += 1;
        var subs = std.mem.split(u8, line, ".");
        while (subs.next()) |sub| {
            var nums = std.mem.splitAny(u8, sub, symbols);
            _ = nums;
        }
        var i: u16 = 0;
        while (i < line.len) {
            const current: u8 = line[i];
            var endingIdx: u16 = i;
            if (std.ascii.isDigit(current)) {
                while (endingIdx < line.len and std.ascii.isDigit(line[endingIdx])) {
                    endingIdx = endingIdx + 1;
                }
                //print("Start and Ending Positions: {d} | {d}\n", .{ i, endingIdx - 1 });
                var counted_already: bool = false;
                for (i..endingIdx) |curr| {
                    var adj_curr: usize = @intCast(line_len * (lineNum - 1) + curr);
                    print("Adjusted Comp: {d}\n", .{adj_curr});
                    for (sym_list.items, 0..) |symbol_pos, t_idx| {
                        if (!counted_already and isAPart(adj_curr, symbol_pos, line.len)) {
                            counted_already = true;
                            sum += try std.fmt.parseInt(u64, line[i..endingIdx], 10);
                            print("Part Number: {s}\n", .{line[i..endingIdx]});
                            if (sym_mirror.items[t_idx] == '*') {
                                if (gears.contains(symbol_pos)) {
                                    var pt = gears.getPtr(symbol_pos).?;
                                    try pt.insert(pt.items.len, try std.fmt.parseInt(u64, line[i..endingIdx], 10));
                                } else {
                                    var newArray = std.ArrayList(usize).init(allocator);
                                    try newArray.insert(0, try std.fmt.parseInt(u64, line[i..endingIdx], 10));
                                    _ = try gears.fetchPut(symbol_pos, newArray);
                                }
                            }
                        }
                    }
                }
                i = endingIdx + 1;
                continue;
            }
            i = i + 1;
        }
    }
    var gears_iterator = gears.iterator();
    while (gears_iterator.next()) |gear| {
        if (gear.value_ptr.*.items.len > 1) {
            print("A gear is located at: {d}\n", .{gear.key_ptr.*});
            var tSum: u64 = 1;
            for (gear.value_ptr.*.items) |item| {
                print("Add Mul of : {d}\n", .{item});
                tSum *= item;
            }
            part2Sum += tSum;
        }
    }
    print("Answer for Day 3 part 1 is: {d}\n", .{sum});
    print("Answer for Day 3 part 2 is: {d}\n", .{part2Sum});
}

pub fn isAPart(a: usize, b: usize, lineLength: usize) bool {
    var larger: usize = 0;
    var smaller: usize = 0;
    if (a > b) {
        larger = a;
        smaller = b;
    } else {
        larger = b;
        smaller = a;
    }
    var diff = larger - smaller;
    var isAPartResult: bool = (diff == 1) or (diff == lineLength) or (diff == lineLength + 1) or (diff == lineLength - 1);

    return isAPartResult;
}
