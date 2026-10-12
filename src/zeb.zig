const std = @import("std");
const web = @import("web/root.zig");
const decode_uri = web.decode_uri;
const encode_uri = web.encode_uri;

pub const DecodeError = decode_uri.DecodeError;
pub const decodeURIAlloc = decode_uri.decodeURIAlloc;
pub const decodeURIComponentAlloc = decode_uri.decodeURIComponentAlloc;

pub const EncodeError = encode_uri.EncodeError;
pub const encodeURIAlloc = encode_uri.encodeURIAlloc;
pub const encodeURIComponentAlloc = encode_uri.encodeURIComponentAlloc;

const url_bytes_max = 64 * 1024; // 64 KiB;

const Command = enum { encode, decode };
const SubCommand = enum { uri, uri_component };

fn parseSubCommand(value: []const u8) ?SubCommand {
    if (std.mem.eql(u8, value, "uri")) return .uri;
    if (std.mem.eql(u8, value, "uriComponent")) return .uri_component;
    return null;
}

fn bufferedPrintToStdout(io: std.Io, string: []const u8) !void {
    var buffer: [url_bytes_max + 1]u8 = undefined;
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
            const sub_command = parseSubCommand(args.next() orelse "") orelse try fail(init.io, "Should only use uri or uriComponent");
            const uri = args.next() orelse try fail(init.io, "Requires URL");
            switch (sub_command) {
                .uri => {
                    const decoded = try decodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    try bufferedPrintToStdout(init.io, decoded);
                },
                .uri_component => {
                    const decoded = try decodeURIComponentAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    try bufferedPrintToStdout(init.io, decoded);
                },
            }
        },
        .encode => {
            const sub_command = parseSubCommand(args.next() orelse "") orelse try fail(init.io, "Should only use uri or uriComponent");
            const uri = args.next() orelse try fail(init.io, "Requires URL");
            switch (sub_command) {
                .uri => {
                    const encoded = try encodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(encoded);
                    try bufferedPrintToStdout(init.io, encoded);
                },
                .uri_component => {
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
