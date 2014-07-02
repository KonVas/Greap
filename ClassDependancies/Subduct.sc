
TrigSubduct {

	*new { |func, args, trig, fadeTime = 0.02|
		var lockedTrig, lockedArgs, prevArgs, prevSwitchArgs, prev, now, env;
		 // don't respond to trigger while crossfading
		lockedTrig = Trig.kr(trig, fadeTime);
		// ... and don't register any change during that time, but do register the initial value.
		lockedArgs = Latch.kr(args, lockedTrig + Impulse.kr(0));
		// keep previous input
		prevArgs = LastValue.kr(lockedArgs);
		// 1. when a change happens, jump instantly to prevArgs, after fadeTime, back to new ones
		prevSwitchArgs = Select.kr(lockedTrig, [lockedArgs, prevArgs]);
		prev = func.valueArray(prevSwitchArgs);
		now = func.valueArray(lockedArgs);
		// 2. the same function with new args, indistinguishable from prev with where = 0
		env = EnvGen.kr(Env([0, 1, 0], [fadeTime, 0]), lockedTrig);
		// crossfade from 1. to 2.
		^SelectX.new1(now.rate, env, [prev, now])
	}
}

// here it may still be needed to delay one of the triggers
TrigSubduct1 {

	*new { |func, args, trig|
		var prevArgs, prevSwitchArgs, prev, now;
		// keep previous input
		prevArgs = LastValue.kr(args);
		// when a change happens, jump instantly to prevArgs, after one control period, back to new ones
		prevSwitchArgs = Select.kr(trig, [args, prevArgs]);
		prev = func.valueArray(prevSwitchArgs);
		now = func.valueArray(args);
		// 2. the same function with new args, indistinguishable from prev with where = 0
		// crossfade from 1. to 2.
		^SelectX.new1(now.rate, trig, [prev, now])
	}

}

Subduct  {

	*new { |func, args, fadeTime|
		// register any change of the argument ugens passed in
		var trig = Changed.kr(args).asArray.sum;
		^if(fadeTime.isNil) {
			TrigSubduct1.new(func, args, trig)
		} {
			TrigSubduct.new(func, args, trig, fadeTime)
		}
	}


}

+ Function {
	xfade { |args, fadeTime|
		^Subduct.new(this, args, fadeTime)
	}
}


/*
x = { |freq=600| Subduct({ |freq| SinOsc.ar(freq) }, freq, 2) * 0.1 }.play;
x.set(\freq, 700);



x.set(\freq, rrand(400, 700));

x = { |freq=600| Subduct({ |freq| SinOsc.ar(freq) }, freq) * 0.1 }.play;
x.set(\freq, 700);
x.set(\freq, rrand(400, 700));


x = { |freq=600| { |x| SinOsc.ar(x) }.xfade(freq) * 0.1 }.play;
x.set(\freq, 700);
x.set(\freq, rrand(400, 700));

{ Subduct({ |val| K2A.ar(val) }, LFNoise0.kr(400)) }.plot;
{ Subduct({ |val| LFPulse.ar(val + 2 * 500) }, LFNoise0.kr(140)) }.plot(0.03);
{ Subduct({ |val| LFPulse.ar(val) }, LFPulse.kr(20).range(500, 1000), 0.01) }.plot(0.05);
{ Subduct({ |val| LFPulse.ar(val) }, LFPulse.kr(20).range(500, 1000)) }.plot(0.05);
{ Subduct({ |val| val }, LFPulse.kr(40).range(500, 1000)) }.plot(0.05);

// comparison
{ var a, b; b = Impulse.kr(10, 0.5); a = EnvGen.kr(Env([0, 1, 0], [0, 0]), b);  [a, b] }.plot(0.1);
*/