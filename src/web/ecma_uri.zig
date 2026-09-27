const std = @import("std");
const decodeURI = @import("decodeURI.zig");
const encodeURI = @import("encodeURI.zig");

pub const DecodeError = decodeURI.DecodeError;
pub const decodeURIAlloc = decodeURI.decodeURIAlloc;

pub const EncodeError = encodeURI.EncodeError;
pub const encodeURIAlloc = encodeURI.encodeURIAlloc;

const URL_BYTES_MAX = 64 * 1024; // 64 KiB;

pub fn main(init: std.process.Init) !void {
    const args = try std.process.Args.Iterator.initAllocator(
        init.minimal.args,
        init.gpa,
    );
    defer args.deinit();

    _ = args.next(); // First arg is executable path name

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--encode")) {
            const url = args.next();
            if (!url) {
                @panic("Requires URL");
            }

        } else if (std.mem.eql(u8, arg, "--decode")) {
            var urlBuffer: [URL_BYTES_MAX]u8 = undefined;
        } else {
            // TODO: Print usage
        }
    }
}

fn encode(allocator: std.mem.Allocator, url: []const u8) void {}

test "decodeURI" {
    _ = @import("decodeURI.zig");
}

test "encodeURI" {
    _ = @import("encodeURI.zig");
}
