package;

import ui.ModifierMenu;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.ui.Window;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.AsyncErrorEvent;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import shaderslmfao.BuildingShaders.BuildingShader;
import shaderslmfao.BuildingShaders;
import shaderslmfao.ColorSwap;
import ui.PreferencesMenu;
import StoryMenuState;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end
#if desktop
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	var startedIntro:Bool;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	var lastBeat:Int = 0;
	var swagShader:ColorSwap;
	var alphaShader:BuildingShaders;
	var thingie:FlxSprite;

	var video:Video;
	var netStream:NetStream;
	private var overlay:Sprite;

	override public function create():Void
	{
		CoolUtil.loadMods();
		
		startedIntro = false;

		FlxG.game.focusLostFramerate = 60;

		swagShader = new ColorSwap();
		alphaShader = new BuildingShaders();

		FlxG.sound.muteKeys = [ZERO];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('test-engine', 'testdevs');
		PreferencesMenu.initPrefs();
		ModifierMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		if (FlxG.save.data.seenVideo != null)
		{
			VideoState.seenVideo = FlxG.save.data.seenVideo;
		}

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});

		#if discord_rpc
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end
	}

	private function client_onMetaData(metaData:Dynamic)
	{
		video.attachNetStream(netStream);

		video.width = video.videoWidth;
		video.height = video.videoHeight;
		// video.
	}

	private function netStream_onAsyncError(event:AsyncErrorEvent):Void
	{
		trace("Error loading video");
	}

	private function netConnection_onNetStatus(event:NetStatusEvent):Void
	{
		if (event.info.code == 'NetStream.Play.Complete')
		{
			// netStream.dispose();
			// FlxG.stage.removeChild(video);

			startIntro();
		}

		trace(event.toString());
	}

	private function overlay_onMouseDown(event:MouseEvent):Void
	{
		netStream.soundTransform.volume = 0.2;
		netStream.soundTransform.pan = -1;
		// netStream.play(Paths.file('music/kickstarterTrailer.mp4'));

		FlxG.stage.removeChild(overlay);
	}

	var logoBl:FlxSprite;

	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		Main.fpsCounter.visible = PreferencesMenu.getPref('fps-counter');

		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		}

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');

		logoBl.updateHitbox();

		logoBl.shader = swagShader.shader;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);

		gfDance.shader = swagShader.shader;

		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.onComplete = function() FlxG.switchState(new VideoState());

		startedIntro = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		#if !desktop
		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;
			// netStream.play(Paths.file('music/kickstarterTrailer.mp4'));
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			new FlxTimer().start(2, function(tmr:FlxTimer){
				FlxG.switchState(new MainMenuState());
			});
		}
		#else
		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.onComplete = null;
			// netStream.play(Paths.file('music/kickstarterTrailer.mp4'));
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Get current version of Test Engine
				if (PreferencesMenu.getPref('check-updates')) {

					var http = new haxe.Http("https://raw.githubusercontent.com/Test-Engine-Team/Test-Engine-V2---FNF/master/Version.txt");
					var returnedData:Array<String> = [];
					var curVer = Application.current.meta.get('version');

					http.onData = function(data:String)
					{
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						if (!curVer.contains(returnedData[0].trim()) && !OutdatedState.leftState)
						{
							trace('L your outdated ' + returnedData[0] + ' != ' + curVer);
							OutdatedState.newVer = returnedData[0];
							FlxG.switchState(new OutdatedState());
						}
						else
						{
							trace('user is ok :)');
							FlxG.switchState(new MainMenuState());
						}
					}

					http.onError = function(error)
					{
						trace('error: $error');
						FlxG.switchState(new MainMenuState()); // fail but we go anyway
					}

					http.request();
				}
				else
				{
					FlxG.switchState(new MainMenuState()); // fail but we go anyway
				}
			});
		}
		// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		#end

		if (!pressedEnter && skippedIntro && !transitioning && FlxG.keys.justPressed.FIVE) {
			OutdatedState.newVer = "1.0.0";
			FlxG.switchState(new OutdatedState());
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		if (controls.UI_LEFT)
			swagShader.update(-elapsed * 0.1);

		if (controls.UI_RIGHT)
			swagShader.update(elapsed * 0.1);

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var isRainbow:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (!startedIntro)
			return ;

		if (skippedIntro)
		{
			logoBl.animation.play('bump', true);

			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		else
		{
			FlxG.log.add(curBeat);
			// if the user is draggin the window some beats will
			// be missed so this is just to compensate
			if (curBeat > lastBeat)
			{
				for (i in lastBeat...curBeat)
				{
					switch (i + 1)
					{
						case 1:
							createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
						// credTextShit.visible = true;
						case 3:
							addMoreText('present');
						// credTextShit.text += '\npresent...';
						// credTextShit.addText();
						case 4:
							deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = 'In association \nwith';
						// credTextShit.screenCenter();
						case 5:
							createCoolText(['In association', 'with']);
						case 7:
							addMoreText('newgrounds');
							ngSpr.visible = true;
						// credTextShit.text += '\nNewgrounds';
						case 8:
							deleteCoolText();
							ngSpr.visible = false;
						// credTextShit.visible = false;

						// credTextShit.text = 'Shoutouts Tom Fulp';
						// credTextShit.screenCenter();
						case 9:
							createCoolText([curWacky[0]]);
						// credTextShit.visible = true;
						case 11:
							addMoreText(curWacky[1]);
						// credTextShit.text += '\nlmao';
						case 12:
							deleteCoolText();
						// credTextShit.visible = false;
						// credTextShit.text = "Friday";
						// credTextShit.screenCenter();
						case 13:
							addMoreText('Friday');
						// credTextShit.visible = true;
						case 14:
							addMoreText('Night');
						// credTextShit.text += '\nNight';
						case 15:
							addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

						case 16:
							skipIntro();
					}
				}
			}
			lastBeat = curBeat;
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
