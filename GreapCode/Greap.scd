s = Server.default.reboot;

s.waitForBoot({ {

	var cs, x, w, cc, o, r, g, q, sl=();
	~i=0; ~mapper = (0..10);

	~sounds = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
	//	~sounds.dict.keys;

/////////////////Mapping///////////////
~cc=([
	(0:\gate, 1:\posLo, 2:\posHi, 3:\posDev, /*9:\pan,*/ 9:\panMax, 7:\amp), //scroller left/right only

	(0:\gate, 3:\rateDev, 2:\posRateE, 1:\posLo, /*9:\pan,*/ 9:\panMax, 7:\amp), //bending 3=up/down of left hand

	(0:\gate, 2:\trigRate, 4:\granDur, 1:\posDev, 9:\panMax, 7:\amp), //stretch left/right only

	(0:\gate, 1:\rateDev, 2:\granDur, 5:\rate, 9:\panMax, 7:\amp), //bending_2 5=up/down of right hand

	(0:\gate, 3:\trigRate, 5:\rateDev, 8:\granDur, 9:\panMax, 7:\amp) //cloudy up/down only
]);

///////////add Specs//////////////

Spec.add(\posLo, [0.01, 0.99, \lin, 0.01, 0.5]);
Spec.add(\posHi, [0.01, 0.99, \lin, 0.01, 0.6]);
Spec.add(\posRateE, [-3, 4, \lin, 0.01, 0]);
Spec.add(\posRateM, [0.1, 10, \lin, 0.01, 1]);
Spec.add(\posDev, [0.01, 0.5, 5, 0, 0.05]);
Spec.add(\trigRate, [1, 200, \lin, 0.01, 100]);
Spec.add(\trigRateDev, [0.0, 1, \lin, 0.01, 0]);
Spec.add(\trigRateOsc, [0.1, 2, \lin, 0.01, 3]);
Spec.add(\granDur, [0.03, 0.3, \lin, 0.01]);
Spec.add(\granDurDev, [0.0, 0.95, \lin, 0.01, 0]);
Spec.add(\rate, [0.1, 4, \lin, 0.01, 1]);
Spec.add(\rateDev, [0.0, 0.99, \lin, 0.01, 0.05]);
Spec.add(\panMax, [0.0, 1, \lin, 0.005, 0.8]);
Spec.add(\amp, [0.1, 1.0, \lin, 0.01, 0.25]);



	cs=(
		posLo:\posLo.asSpec, posHi:\posHi.asSpec, rate:\rate.asSpec, amp:\amp.asSpec, posDev:\posDev.asSpec,
		posRateE:\posRateE.asSpec, posRateM:\posRateM.asSpec, trigRate:\trigRate.asSpec,
		trigRateDev:\trigRateDev.asSpec, trigRateOsc:\trigRateOsc.asSpec, granDur:\granDur.asSpec,
		granDurDev:\granDurDev.asSpec, panMax:\panMax.asSpec
	);


	SynthDef(\Granular, { |
		out = 0, gate=0, bufnum, posLo = 0.01, posHi = 0.99,
		posRateE = 0, posRateM = 1, posDev = 0.01, trigRate = 100, trigRateDev = 0,
		trigRateOsc = 1, granDur = 0.1, granDurDev = 0, rate = 1.0, rateDev = 0, ampDev,
		panMax = 1, amp = 0.1, interp = 4, cutOfFreq = 80, envbuf, crossFade=2|

		var trig, pan, pos, bufDur, bufDurSection, posDif, posRate;

		posDif = LPF.kr(posHi, cutOfFreq) - LPF.kr(posLo, cutOfFreq);
		bufDur = BufDur.kr(bufnum);
		bufDurSection = bufDur * posDif;
		trig = Impulse.kr(LFDNoise3.kr(Lag.kr(trigRateOsc), Lag.kr(trigRate, 0.3) *
			Lag.kr(trigRateDev), Lag.kr(trigRate)));
		posRate = 10 ** Lag.kr(posRateE, 0.3) * Lag.kr(posRateM, 0.3);
		pos = posLo * bufDur +
		(Phasor.ar(0, BufRateScale.kr(bufnum) * posRate / SampleRate.ir, posLo.lag(0.3) * bufDur, posHi.lag(0.3) * bufDur) +
			(TRand.kr(-0.5, 0.5, trig) * Lag.kr(posDev) * bufDur)).mod(bufDurSection);

		pan = Demand.kr(trig, 0, Dseq([Median.kr(31, panMax), panMax.neg],inf) * 0.999);

		OffsetOut.ar(out,
			Limiter.ar(
					GrainBuf.ar(2
						, trig
						, Lag.kr(granDur, 0.3) * (TRand.kr(-1, 1.0, trig) * Lag.kr(granDurDev) + 1)
						, bufnum
						//, WhiteNoise.ar(rateDev.lag(0.3), rate.lag(0.3) )
						, Lag.kr(rate) * (TRand.kr(-1, 1.0, trig) * Median.kr(31,rateDev) + 1)
						, Median.kr(31, pos) / bufDur
						, interp
						, pan
						, -1
						, 512
						, Amplitude.kr( Median.kr(31, amp  ), 0.6, 0.6)
					)//end of GrainBuf.
			) * EnvGen.ar(Env.adsr(0.3), gate)
		)

	}).add;


	s.sync;
	x=Synth(\Granular, [\granDur, 0.3, \posDev, 0.1, \crossFade,8, \bufnum, ~sounds ]);


	////////////////////////Slider Window///////////////////////////

	{
		w=Window.new("Greap", Rect(10, 20, 980, 350)).front;//x,y,width,height
		w.view.decorator=f=FlowLayout(w.view.bounds);
		w.alwaysOnTop_(true); w.background = Color.black.alpha = 0.6;


		[\posLo, \posHi, \posDev, \posRateE, \posRateM,
			\rate, \granDur, \amp, \trigRate, \trigRateOsc, \trigRateDev,
			\granDurDev, \rateDev, \panMax, \gate].do({|par|
			x.get(par, {|val|
				{sl[par]=EZSlider(w.view, 300@35, par, cs[par], {|ez| x.set(par, ez.value)}, val)
					.round_(0.01)
					.setColors(Color.grey(0.3), Color.grey(0.7), Color.grey(alpha:0.5))
					.font_(Font("Monaco", 11));
				}.defer;
			});
		});

		w.front;
		w.refresh;
		w.onClose_({ f.free; x.free; ~midiControl.free; ~sounds.free; ~freq.free; });

	}.defer;
	{
		///////////effects////////
		~freq={LFNoise1.kr(0.5,4000,4200)}.play;
		~fxView = ListView(w,Rect(10,10,180,120))
		.items_([ "No Filter", "RLPF", "RHPF", "BPF", "Resonz", "MoogFF", "GVerb" ])
		.background_(Color.grey)
		.hiliteColor_(Color.green(alpha:0.8))
		.action_({arg v;
			v.value.switch(
				0,{try{f.free};"test".postln},
				1,{try{f.free};f={ReplaceOut.ar(0, RLPF.ar(In.ar(0,2),In.kr(0,1),0.2,0.3))}.play(addAction:\addToTail)},
				2,{try{f.free};f={ReplaceOut.ar(0, RHPF.ar(In.ar(0,2),In.kr(0,1),0.2,0.3))}.play(addAction:\addToTail)},
				3,{try{f.free};f={ReplaceOut.ar(0, BPF.ar(In.ar(0,2),In.kr(0,1),0.2,1.5))}.play(addAction:\addToTail)},
				4,{try{f.free};f={ReplaceOut.ar(0, Resonz.ar(In.ar(0,2),In.kr(0,1),0.2,2))}.play(addAction:\addToTail)},
				5,{try{f.free};f={ReplaceOut.ar(0, MoogFF.ar(In.ar(0,2),In.kr(0,1),1.5))}.play(addAction:\addToTail)},
				6,{try{f.free};f={ReplaceOut.ar(0, GVerb.ar(In.ar(0,2)))}.play(addAction:\addToTail)},
			);
		});

	}.defer;


	(
		////Presets or Scenes////
		{
			~presetMenu=EZPopUpMenu.new(w, 220@60, "Scene: ");

			~presetMenu.addItem(\Scroller,
				{
					|a, rate=1.0, rateDev=0.0, posLo=0.01, posHi=0.99, trigRate=100, posRateM=1, posRateE=0, granDur=0.3|
					~i=0;
					x.set(\rate, rate, \rateDev, rateDev, \posLo, posLo, \posHi, posHi, \trigRate, trigRate,
						\posRateM, posRateM, \posRateE, posRateE, \granDur, granDur
					);
					sl[\rateDev].value_(rateDev).doAction;
					sl[\rate].value_(rate).doAction; sl[\posLo].value_(posLo).doAction; sl[\granDur].value_(granDur);
					sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
					sl[\posRateM].value_(posRateM).doAction; sl[\posRateE].value_(posRateE).doAction
			});

			~presetMenu.addItem(\Bending,
				{
					|a, rateDev=0.0, posLo=0.01, posHi=0.99, trigRate=150, posRateM=0.1, posRateE=1|
					~i=1;
					x.set( \posLo, posLo, \posHi, posHi, \trigRate, trigRate, \posRateE, posRateE, \posRateM, posRateM
					);
					/*sl[\bufnum].value_(bufnum).doAction;*/ sl[\rateDev].value_(rateDev).doAction;
					sl[\posLo].value_(posLo).doAction; sl[\posRateE].value_(posRateE).doAction;
					sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
					sl[\posRateM].value_(posRateM).doAction;
			});

			~presetMenu.addItem(\Stretch,
				{|a, rateDev=0.1, rate=1.0, granDur=0.3, posLo=0.01,
					posHi=0.99, posDev=0.12, trigRate=20, posRateM=0, posRateE=0, trigRateDev=0.1 |
					~i=2;
					x.set(\rate, rate,  \granDur, granDur, \rateDev, rateDev, \posLo, posLo, \posDev, posDev,
						\posHi, posHi, \trigRate, trigRate, \posRateM, posRateM, \trigRateDev, trigRateDev, \posRateE, posRateE
					);
					sl[\rate].value_(rate).doAction; sl[\rateDev].value_(rateDev).doAction; sl[\posRateE].value_(posRateE).doAction;
					sl[\posDev].value_(posDev).doAction; sl[\granDur].value_(granDur).doAction;
					sl[\posLo].value_(posLo).doAction; /*sl[\bufnum].value_(bufnum).doAction;*/
					sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
					sl[\posRateM].value_(posRateM).doAction; sl[\trigRateDev].value_(trigRateDev).doAction;
			});

			~presetMenu.addItem(\Bending_2,
				{
					|a, posDev=0.01, pan=0.0, rateDev=0.0, posLo=0.01, posHi=0.99, trigRate=200, posRateM=0.1, posRateE=1, granDur=0.3|
					~i=3;
		x.set( \posDev, posDev, \pan, pan, \granDur, granDur, \posLo, posLo, \posHi, posHi, \trigRate, trigRate,
						\posRateE, posRateE, \posRateM, posRateM);
					/*sl[\bufnum].value_(bufnum).doAction;*/ sl[\rateDev].value_(rateDev).doAction;
					sl[\posLo].value_(posLo).doAction; sl[\posRateE].value_(posRateE).doAction;
					sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
					sl[\posRateM].value_(posRateM).doAction; sl[\granDur].value_(granDur).doAction;
					sl[\posDev].value_(posDev).doAction;
			});

			~presetMenu.addItem(\CloudyDev,
				{|a,rate=1.0, posLo=0.01, granDur=0.03, posHi=0.99, trigRate=180, trigRateDev=0.0, posRateE=4, panMax=0.5|
					~i=4;
					x.set(\rate, rate, \panMax, panMax, \bufnum, ~sounds, \posLo, posLo, \posHi, posHi, \granDur, granDur,
						\trigRate, trigRate,  \trigRateDev, trigRateDev, \posRateE, posRateE
					);
					sl[\rate].value_(rate).doAction; sl[\posLo].value_(posLo).doAction; sl[\posRateE].value_(posRateE).doAction; sl[\panMax].value_(panMax).doAction;
					sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction; sl[\granDur].value_(granDur).doAction;
					sl[\trigRateDev].value_(trigRateDev).doAction; /* sl[\bufnum].value_(bufnum).doAction;*/
			});

			~presetMenu.setColors(Color.grey,Color.white).font_(Font("Monaco", 14, bold:true));

		}.defer;
	);


	Button(w.view, 90@60)
	.states_([
		["Paused II", Color.white, Color.black],
		["Playing", Color.black, Color.red]
	]).action_({|state| if(state.value==1){x.run(true)}; if(state.value==0){x.run(false)} });


	~midiControl = MIDIFunc.cc({|val, num|
		//[val, num].postln;
		if(~cc.at(~i)[num]!=nil, {
			{sl[~cc.at(~i)[num]].valueAction_(sl[~cc.at(~i)[num]].controlSpec.map(val/127).lag(0.1))}.defer;
		});
	}, ~mapper);


	}.fork(AppClock);
	//s.plotTree.window(w);
});

/////some code to open GECO and connect MIDI automatically.

fork{
"~/Documents/Dev/Projects/Greap/GECOScript/GECOMapSC.geco".openOS;
5.0.wait; // wait for the amount of time that GECOMap.SC needs to start its midi ports
MIDIIn.connectAll;
}

///Testing!!!!!!!!