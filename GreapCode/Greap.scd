Server.default.boot;
Server.default.waitForBoot({
	{

		var cs, x, w, p, sl=();
		~i=0; ~mapper = (0..10); ~presetPointer=0; ~soundsPath;

		s.sync;
		~soundsPath = PathName.new("Sounds/".resolveRelative);
		~soundsPath.filesDo({|path| path.fileNameWithoutExtension.postln });
		~sounds = BEERffers.loadDirectory(~soundsPath.pathOnly, s);

		/*~sounds.dict.keys;*/

		/////////////////Mapping///////////////

		~cc=([
			(0:\gate, 1:\posLo, 2:\posHi, 3:\posDev, 9:\panMax, 7:\amp), //scroller left/right only
			(0:\gate, 3:\rateDev, 2:\posRateE, 1:\posLo, 9:\panMax, 7:\amp), //bending 3=up/down of left hand
			(0:\gate, 1:\trigRate, 2:\granDur, 4:\posDev, 9:\panMax, 7:\amp), //stretch left/right only
			(0:\gate, 1:\rateDev, 2:\granDur,  5:\rate, 3:\trigRate, 9:\panMax, 7:\amp), //bending_2 5=up/down of right hand
			(0:\gate, 3:\trigRate, 5:\rateDev, 8:\granDur, 7:\amp) //cloudy up/down only
		]);

		///////////add Specs//////////////

		Spec.add(\posLo, [0.01, 0.99, \lin, 0.01]);
		Spec.add(\posHi, [0.01, 0.99, \lin, 0.01]);
		Spec.add(\posRateE, [-3, 4, \lin, 0.01]);
		Spec.add(\posRateM, [0.1, 10, \lin, 0.01]);
		Spec.add(\posDev, [0.01, 0.5, 5, 0]);
		Spec.add(\trigRate, [0, 200, \lin, 0.01]);
		Spec.add(\trigRateDev, [0.0, 1, \lin, 0.01]);
		Spec.add(\trigRateOsc, [0.1, 2, \lin, 0.01]);
		Spec.add(\granDur, [0.03, 0.4, \lin, 0.01]);
		Spec.add(\granDurDev, [0.0, 0.95, \lin, 0.01]);
		Spec.add(\rate, [0.1, 4, \lin, 0.01]);
		Spec.add(\rateDev, [0.0, 0.99, \lin, 0.01]);
		Spec.add(\panMax, [0.0, 1, \lin, 0.005]);
		Spec.add(\amp, [0.01, 0.8, \lin, 0.01]);
		Spec.add(\bufnum, [0, ~sounds.dict.size, \lin, 1]);
		Spec.add(\crossFade, [0, 8, \lin, 0.01]);
		Spec.add(\gate, [0, 1, \lin, 1]);


		cs=(
			posLo:\posLo.asSpec, posHi:\posHi.asSpec, rate:\rate.asSpec, amp:\amp.asSpec, posDev:\posDev.asSpec,
			posRateE:\posRateE.asSpec, posRateM:\posRateM.asSpec, trigRate:\trigRate.asSpec, gate:\gate.asSpec,
			trigRateDev:\trigRateDev.asSpec, trigRateOsc:\trigRateOsc.asSpec, granDur:\granDur.asSpec,
			granDurDev:\granDurDev.asSpec, panMax:\panMax.asSpec, bufnum:\bufnum.asSpec, crossFade:\crossFade.asSpec
		);


		SynthDef(\Granular, { |
			out = 0, gate, bufnum, posLo, posHi,
			posRateE, posRateM, posDev, trigRate, trigRateDev,
			trigRateOsc, granDur, granDurDev, rate = 1.0, rateDev,
			panMax, amp, interp = 4, cutOfFreq = 80, crossFade|

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
					Subduct({
						|bufnum|
						GrainBuf.ar(2
							, trig
							, Lag.kr(granDur, 0.3) * (TRand.kr(-1, 1.0, trig) * Lag.kr(granDurDev, 0.3) + 1)
							, bufnum
							//, WhiteNoise.ar(rateDev.lag(0.3), rate.lag(0.3) )
							, Lag.kr(rate, 0.3) * (TRand.kr(-1, 1.0, trig) * Median.kr(31,rateDev) + 1)
							, Median.kr(31, pos) / bufDur
							, interp
							, pan
							, -1
							, 512
							, amp
						)//end of GrainBuf.
					}, bufnum, crossFade)
				) * EnvGen.ar(Env.adsr(attackTime:0.1, releaseTime:0.5), gate)
			)
		}).add;

		s.sync;
		x=Synth.new(\Granular);
		NodeWatcher.register(x);


		////////////////////////Slider Window///////////////////////////

		{
			w=Window.new("Greap", 500@735).front;//x,y,width,height
			w.view.decorator = f = FlowLayout.new( w.view.bounds, 10@10, 20@5 );
			w.background = Color.black.alpha = 0.6;

			[\posLo, \posHi, \posDev, \posRateE, \posRateM,
				\rate, \granDur, \amp, \trigRate, \trigRateOsc, \trigRateDev,
				\granDurDev, \rateDev, \panMax, \gate, \bufnum, \crossFade  ].do({|par|
				x.get(par, {|val|
					{sl[par]=EZSlider(w.view, 430@35, par, cs[par], {|ez| x.set(par, ez.value)}, val)
						.round_(0.01)
						.setColors(Color.grey(0.3), Color.grey(0.7), Color.grey(alpha:0.8))
						.font_(Font("Monaco", 10));
					}.defer;
				});
			});

			w.onClose_({ f.free; x.free; ~midiControl.free; ~sounds.free; ("GoodBye Master " ++ Pipe("whoami", "r").getLine).postln });
		}.defer;

		Button(w.view, 100@35)
		.states_([
			["Stopped", Color.white, Color.black],
			["Playing", Color.black, Color.red]
		]).action_({|state|
			if( state.value == 1 ){x.run( true )};
			if( state.value == 0 ){x.run( false )}
		}).valueAction_(1);

		(
			//// Scenes ////
			{
				~presetMenu=EZPopUpMenu.new(w, 220@35, "Scene: ");

				~presetMenu.addItem(\Scroller,
					{
						|a, rate=1.0,  gate=0, amp=0.6, crossFade=0.0, rateDev=0.0, posLo=0.01, posHi=0.99, trigRate=100, posRateM=1, posRateE=0.0, granDur=0.3|
						~i=0;
						x.set(\rate, rate, \amp, amp, \crossFade, crossFade, \rateDev, rateDev, \bufnum, ~sounds[\addNameOfSound], \gate, gate,
							\posLo, posLo, \posHi, posHi, \trigRate, trigRate, \posRateM, posRateM, \posRateE, posRateE, \granDur, granDur
						);
						/*sl[\bufnum].value_(bufnum).doAction;*/ sl[\rateDev].value_(rateDev).doAction; sl[\gate].value_(gate).doAction;
						sl[\rate].value_(rate).doAction; sl[\posLo].value_(posLo).doAction; sl[\granDur].value_(granDur);
						sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction; sl[\crossFade].value_(crossFade).doAction;
						sl[\posRateM].value_(posRateM).doAction; sl[\posRateE].value_(posRateE).doAction; sl[\amp].value_(amp).doAction;
				});

				~presetMenu.addItem(\Bending,
					{
						|a, rateDev=0.0, rate=1.0, posLo=0.01, posHi=0.99, trigRate=150, crossFade=3, posRateM=0.1, posRateE=0.3, gate=1|
						~i=1;
						x.set(\bufnum, ~sounds[\addNameOfSound], \rate, rate, \crossFade, crossFade, \gate, gate, \posLo, posLo, \posHi, posHi, \trigRate, trigRate, \posRateE, posRateE, \posRateM, posRateM
						);
						/*sl[\bufnum].value_(bufnum).doAction;*/ sl[\rateDev].value_(rateDev).doAction;
						sl[\rate].value_(rate).doAction; sl[\posLo].value_(posLo).doAction;
						sl[\posRateE].value_(posRateE).doAction; sl[\gate].value_(gate).doAction;
						sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
						sl[\posRateM].value_(posRateM).doAction; sl[\crossFade].value_(crossFade).doAction;
				});

				~presetMenu.addItem(\Stretch,
					{|a, rateDev=0.1, rate=1.0, granDur=0.3, posLo=0.01, gate=1, posHi=0.99, posDev=0.0, trigRate=20, posRateM=0, posRateE= -3,
						trigRateDev=0.1, crossFade=8|
						~i=2;
						x.set(\rate, rate, \gate, gate, \bufnum, ~sounds[\addNameOfSound], \crossFade, crossFade, \granDur, granDur, \rateDev, rateDev, \posLo, posLo, \posDev, posDev,
							\posHi, posHi, \trigRate, trigRate, \posRateM, posRateM, \trigRateDev, trigRateDev, \posRateE, posRateE
						);
						sl[\rate].value_(rate).doAction; sl[\rateDev].value_(rateDev).doAction;
						sl[\posRateE].value_(posRateE).doAction; sl[\posDev].value_(posDev).doAction;
						sl[\granDur].value_(granDur).doAction; sl[\gate].value_(gate).doAction;
						sl[\posLo].value_(posLo).doAction; /*sl[\bufnum].value_(bufnum).doAction;*/
			            sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
						sl[\posRateM].value_(posRateM).doAction; sl[\trigRateDev].value_(trigRateDev).doAction;
						sl[\crossFade].value_(crossFade).doAction;
				});

				~presetMenu.addItem(\Bending_2,
					{
						|a, gate=0, rate=1.0, posDev=0.01, rateDev=0.0, crossFade=0.0, posLo=0.01, posHi=0.99, trigRate=0, posRateM=0.1, posRateE=1, granDur=0.3|
						~i=3;
						x.set(\bufnum, ~sounds[\addNameOfSound], \rate, rate, \posDev, posDev, \gate, gate,
							\granDur, granDur, \posLo, posLo, \posHi, posHi, \trigRate, trigRate,
							\posRateE, posRateE, \posRateM, posRateM,\crossFade, crossFade);

						/*sl[\bufnum].value_(bufnum).doAction;*/ sl[\rateDev].value_(rateDev).doAction;
						sl[\posLo].value_(posLo).doAction; sl[\posRateE].value_(posRateE).doAction;
						sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
						sl[\posRateM].value_(posRateM).doAction; sl[\granDur].value_(granDur).doAction;
						sl[\crossFade].value_(crossFade).doAction; sl[\gate].value_(gate).doAction;
						sl[\posDev].value_(posDev).doAction; sl[\rate].value_(rate).doAction;
				});

				~presetMenu.addItem(\CloudyDev,
					{|a,rate=1.0, gate=0, posLo=0.01, granDur=0.03, crossFade=0.0, posHi=0.99, trigRate=180, trigRateDev=0.0, posRateE=4, panMax=0.99|
						~i=4;
						x.set(\rate, rate, \bufnum, ~sounds[\addNameOfSound],\posLo, posLo, \posHi, posHi, \granDur, granDur, \gate, gate,
							\trigRate, trigRate,  \trigRateDev, trigRateDev, \posRateE, posRateE, \crossFade, crossFade, \panMax, panMax
						);
						sl[\rate].value_(rate).doAction; sl[\posLo].value_(posLo).doAction;
						sl[\posRateE].value_(posRateE).doAction; sl[\gate].value_(gate).doAction;
						sl[\posHi].value_(posHi).doAction; sl[\trigRate].value_(trigRate).doAction;
						sl[\granDur].value_(granDur).doAction; sl[\panMax].value_(panMax).doAction;
						sl[\trigRateDev].value_(trigRateDev).doAction; /* sl[\bufnum].value_(bufnum).doAction;*/
						sl[\crossFade].value_(crossFade).doAction;
				});

			}.defer;
		);


		///MIDI Controls////

		~midiControl = MIDIFunc.cc({|val, num|
			//[val, num].postln;
			if(~cc.at(~i)[num]!=nil, {
				{sl[~cc.at(~i)[num]].valueAction_(sl[~cc.at(~i)[num]].controlSpec.map(val/127).lag(0.1))}.defer;
			});
		}, ~mapper);

		~changePreset = MIDIFunc.cc({|val, num|
			/*"...".postln;*/
			if( val == 127 ){
				~presetPointer = ~presetPointer + 1 % ~presetMenu.items.size;
				{~presetMenu.valueAction_(~presetPointer)}.defer;
			}
		}, ccNum:64);

		///GECO MIDI Initialisation/////

		0.05.wait;
		"GECOMapSC.geco".resolveRelative.openOS;
		6.wait;
		MIDIClient.init;
		0.05.wait;
		MIDIIn.connectAll;
		0.05.wait;
		{ ~presetMenu.valueAction_( ~presetPointer ) }.defer;
		0.05.wait;
		if(x.isPlaying){
			(Post.tab; "Ready To Do Thy Bidding Master " ++ Pipe("whoami", "r").getLine ).asCompileString.postln
		}
	}.fork(AppClock);
})