const std = @import("std");
const realFile = "input.txt";
const testFile = "test.txt";
const input = @embedFile(realFile);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try part_one_and_two(allocator);
}

pub fn part_one_and_two(allocator: std.mem.Allocator) !void {
    var limits = std.StringHashMap(u8).init(allocator);
    _ = try limits.fetchPut("red", 12);
    _ = try limits.fetchPut("green", 13);
    _ = try limits.fetchPut("blue", 14);
    var games = std.mem.split(u8, input, "\r\n");
    std.debug.print("\n", .{});
    var answer: u32 = 0;
    var power_set: u64 = 0;
    while (games.next()) |game| {
        var turns = std.mem.splitBackwards(u8, game, ":");
        var tries = turns.first();
        var game_desc = turns.next().?;
        var game_parts = std.mem.splitBackwards(u8, game_desc, " ");
        var ID = game_parts.first();
        var entries = std.mem.split(u8, tries, ";");
        var this_game_works: bool = true;
        var max_red: u64 = 0;
        var max_blue: u64 = 0;
        var max_green: u64 = 0;
        while (entries.next()) |entry| {
            var mp = std.StringHashMap(u8).init(allocator);
            _ = try mp.fetchPut("red", 0);
            _ = try mp.fetchPut("green", 0);
            _ = try mp.fetchPut("blue", 0);
            var parts = std.mem.split(u8, entry, ",");
            while (parts.next()) |part| {
                var comps = std.mem.split(u8, part, " ");
                _ = comps.first();
                var color_amount = comps.next() orelse "NONE";
                var color_desc = comps.next() orelse "NULL";
                var total: u64 = try std.fmt.parseInt(u64, color_amount, 10);
                if (std.mem.eql(u8, color_desc, "red")) {
                    max_red = @max(max_red, total);
                } else if (std.mem.eql(u8, color_desc, "green")) {
                    max_green = @max(max_green, total);
                } else if (std.mem.eql(u8, color_desc, "blue")) {
                    max_blue = @max(max_blue, total);
                }
                if (limits.get(color_desc) orelse 0 < total) {
                    this_game_works = false;
                }
            }
        }
        if (this_game_works) {
            answer += try std.fmt.parseInt(u32, ID, 10);
        }
        power_set += (max_red * max_green * max_blue);
    }
    std.debug.print("The answer for day 2 part 1 is: {d}\n", .{answer});
    std.debug.print("The answer for day 2 part 2 is: {d}\n", .{power_set});
}
