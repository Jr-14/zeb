const std = @import("std");
const web = @import("web/root.zig");
const decodeURI = web.decodeURI;
const encodeURI = web.encodeURI;

pub const DecodeError = decodeURI.DecodeError;
pub const decodeURIAlloc = decodeURI.decodeURIAlloc;
pub const decodeURIComponentAlloc = decodeURI.decodeURIComponentAlloc;

pub const EncodeError = encodeURI.EncodeError;
pub const encodeURIAlloc = encodeURI.encodeURIAlloc;
pub const encodeURIComponentAlloc = encodeURI.encodeURIComponentAlloc;

const URL_BYTES_MAX = 64 * 1024; // 64 KiB;

const Command = enum { encode, decode };
const SubCommand = enum { uri, uriComponent };

fn bufferedPrintToStdout(io: std.Io, string: []const u8) !void {
    var buffer: [URL_BYTES_MAX + 1]u8 = undefined;
    const line = try std.fmt.bufPrint(&buffer, "{s}\n", .{string});
    try std.Io.File.stdout().writeStreamingAll(io, line);
}

fn fail(io: std.Io, message: []const u8) !noreturn {
    try std.Io.File.stderr().writeStreamingAll(io, message);
    try std.Io.File.stderr().writeStreamingAll(io, "\n");
    std.process.exit(1);
}

pub fn main(init: std.process.Init) !void {
    var args = try std.process.Args.Iterator.initAllocator(
        init.minimal.args,
        init.gpa,
    );
    defer args.deinit();

    _ = args.next(); // First arg is executable path name so we skip it
    const command = std.meta.stringToEnum(Command, args.next() orelse "") orelse try fail(init.io, "Should only use encode or decode");

    switch (command) {
        .decode => {
            const subCommand = std.meta.stringToEnum(SubCommand, args.next() orelse "") orelse try fail(init.io, "Should only use uri or uriComponent");
            const uri = args.next() orelse try fail(init.io, "Requires URL");
            switch (subCommand) {
                .uri => {
                    const decoded = try decodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    try bufferedPrintToStdout(init.io, decoded);
                },
                .uriComponent => {
                    const decoded = try decodeURIComponentAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    try bufferedPrintToStdout(init.io, decoded);
                },
            }
        },
        .encode => {
            const subCommand = std.meta.stringToEnum(SubCommand, args.next() orelse "") orelse try fail(init.io, "Should only use uri or uriComponent");
            const uri = args.next() orelse try fail(init.io, "Requires URL");
            switch (subCommand) {
                .uri => {
                    const encoded = try encodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(encoded);
                    try bufferedPrintToStdout(init.io, encoded);
                },
                .uriComponent => {
                    const encoded = try encodeURIComponentAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(encoded);
                    try bufferedPrintToStdout(init.io, encoded);
                },
            }
        },
    }
}

test {
    _ = @import("web/root.zig");
}
