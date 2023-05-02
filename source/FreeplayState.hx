package;

import haxe.Json;
#if discord_rpc
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

typedef FreeplayJsonShit =
{
	var song:String;
	var color:String;
	var diffs:Array<String>;
	var icon:String;
	var week:Int;
}

typedef FreeplayJsonLoadingShit =
{
	var songs:Array<FreeplayJsonShit>;
	var addBaseSongs:Bool;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	// var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var coolColors:Array<FlxColor> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var songFreeplayShit:FreeplayJsonLoadingShit;

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (openfl.Assets.exists('assets/data/freeplaySongList.json')){
		songFreeplayShit = Json.parse(Assets.getText('assets/data/freeplaySongList.json'));

		for (stuff in songFreeplayShit.songs)
		{
			if (stuff.song != null)
				addSong(stuff.song, stuff.week, stuff.icon, FlxColor.fromString(stuff.color));
		}
		}else{
			songFreeplayShit.addBaseSongs = true;
		}

		if (songFreeplayShit.addBaseSongs)
		{
			addSong('Tutorial', 0, 'gf', 0xff9271fd);

			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad'], 0xff9271fd);

			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster'], 0xff223344);

			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico'], 0xFF941653);

			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom'], 0xFFfc96d7);

			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas'], 0xFFa0d1ff);

			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'], 0xffff78bf);

			addWeek(['Ugh', 'Guns', 'Stress'], 7, ['tankman'], 0xfff6b604);
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			coolColors.push(songs[i].color);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x99000000);
		scoreBG.antialiasing = false;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:FlxColor)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?color:FlxColor)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], color);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.7)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, coolColors[curSelected], CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		PlayState.storyDifficulty = curDifficulty;

		diffText.text = "< " + CoolUtil.difficultyString() + " >";
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		diffText.x = Std.int(scoreBG.x + scoreBG.width / 2);
		diffText.x -= (diffText.width / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:FlxColor;

	public function new(song:String, week:Int, songCharacter:String, color:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
	}
}
