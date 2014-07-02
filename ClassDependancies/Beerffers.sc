/*
BEERffers.loadDirectory("/Users/scottw/Aiyun Piece/Audio/voice/");
BEERffers.dict.keys;
BEERffers('pah14').play
b = BEERffers;
b[\pah14].play

Pbind(\buffer, b[\pah14])
*/

BEERffers {
	classvar <dict;

	*loadDirectory {|path, server|
		if(dict.isNil, {
			dict = IdentityDictionary.new;
		});
		path = PathName(path);

		path.filesDo({|pth|
			var buf;
			buf = Buffer.read(server, pth.fullPath);
			dict[pth.fileNameWithoutExtension.asSymbol] = buf;
		});
	}

	*new {|name|
		^dict[name.asSymbol]
	}

	*at {|name|
		^dict[name.asSymbol]
	}

	*select {|func|
		var keys;
		keys = dict.keys.select(func);
		^keys.collect({|key| dict[key] }).asArray;
	}
}