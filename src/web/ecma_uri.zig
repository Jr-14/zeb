const std = @import("std");
const decodeURI = @import("decodeURI.zig");
const encodeURI = @import("encodeURI.zig");

pub const DecodeError = decodeURI.DecodeError;
pub const decodeURIAlloc = decodeURI.decodeURIAlloc;

pub const EncodeError = encodeURI.EncodeError;
pub const encodeURIAlloc = encodeURI.encodeURIAlloc;

const URL_BYTES_MAX = 64 * 1024; // 64 KiB;

pub fn main(init: std.process.Init) !void {
    var args = try std.process.Args.Iterator.initAllocator(
        init.minimal.args,
        init.gpa,
    );
    defer args.deinit();

    _ = args.next(); // First arg is executable path name

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--encode")) {
            const url = args.next();
            if (url) |u| {
                const encodedURI = try encodeURIAlloc(init.gpa, u[0..]);
                defer init.gpa.free(encodedURI);
                std.debug.print("{s}\n", .{encodedURI});
            } else {
                @panic("Requires URL");
            }
        } else if (std.mem.eql(u8, arg, "--decode")) {
            const url = args.next();
            if (url) |u| {
                const decodedURI = try decodeURIAlloc(init.gpa, u[0..]);
                defer init.gpa.free(decodedURI);
                std.debug.print("{s}\n", .{decodedURI});
            } else {
                @panic("Requires URL");
            }
        } else {
            // TODO: Print usage
            @panic("Should only use --encode or --decode\n");
        }
    }
}

test "decodeURI" {
    _ = @import("decodeURI.zig");
}

test "encodeURI" {
    _ = @import("encodeURI.zig");
}
