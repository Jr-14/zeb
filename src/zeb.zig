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

pub fn main(init: std.process.Init) !void {
    var args = try std.process.Args.Iterator.initAllocator(
        init.minimal.args,
        init.gpa,
    );
    defer args.deinit();

    _ = args.next(); // First arg is executable path name
    const command = std.meta.stringToEnum(Command, args.next() orelse "") orelse {
        @panic("Should only use encode or decode\n");
    };

    switch (command) {
        .decode => {
            const subCommand = std.meta.stringToEnum(SubCommand, args.next() orelse "") orelse {
                @panic("Should only use uri or uriComponent\n");
            };
            var uri = args.next() orelse @panic("Requires URL");
            switch (subCommand) {
                .uri => {
                    const decoded = try decodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    std.debug.print("{s}\n", .{decoded});
                },
                .uriComponent => {
                    const decoded = try decodeURIComponentAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(decoded);
                    std.debug.print("{s}\n", .{decoded});
                },
            }
        },
        .encode => {
            const subCommand = std.meta.stringToEnum(SubCommand, args.next() orelse "") orelse {
                @panic("Should only use uri or uriComponent\n");
            };
            var uri = args.next() orelse @panic("Requires URL");
            switch (subCommand) {
                .uri => {
                    const encoded = try encodeURIAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(encoded);
                    std.debug.print("{s}\n", .{encoded});
                },
                .uriComponent => {
                    const encoded = try encodeURIComponentAlloc(init.gpa, uri[0..]);
                    defer init.gpa.free(encoded);
                    std.debug.print("{s}\n", .{encoded});
                },
            }
        },
    }
}

test {
    _ = @import("web/root.zig");
}
