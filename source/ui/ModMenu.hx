package ui;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import openfl.Assets;
import ui.OptionsState.Page;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class ModMenu extends Page
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var grpIconShit:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	public function new()
	{
		super();

		#if sys
		menuItems = FileSystem.readDirectory('./mods');

		menuItems.remove('ModEnabled.txt');
		menuItems.remove('Global');
		menuItems.push('Base Game');
		#end

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		grpIconShit = new FlxTypedGroup<FlxSprite>();
		add(grpIconShit);

		regenMenu();
	}

	private function regenMenu():Void
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			#if sys
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);

			/*var icon:FlxSprite = new FlxSprite(songText.x, songText.y);

			if (Assets.exists(Sys.getCwd() + "mods/" + menuItems[i] + "/_polymod_icon.png"))
			{
				var imageDataRaw = File.getBytes(Sys.getCwd() + "mods/" + menuItems[i] + "/_polymod_icon.png");
				var graphicData = BitmapData.fromBytes(imageDataRaw);

				icon.loadGraphic(graphicData, false, 0, 0, false, menuItems[i]);
			}
			else {
				trace(Paths.image('modtemp'));
				icon.loadGraphic(Paths.image('modtemp'), false, 0, 0, false, menuItems[i]);
			}

			grpIconShit.add(icon);*/
			#end
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.R)
		{
			#if sys
			menuItems = FileSystem.readDirectory('./mods');
			menuItems.remove('ModEnabled.txt');
			menuItems.remove('Global');
			menuItems.push('Base Game');
			regenMenu();
			#end
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			#if sys
			File.saveContent('./mods/ModEnabled.txt', daSelected);
			FlxG.switchState(new TitleState());
			#end
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			for (icon in grpIconShit.members)
				icon.y = item.targetY;

			bullShit++;

			item.alpha = 0.6;
			for (icon in grpIconShit.members)
				icon.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				for (icon in grpIconShit.members)
					icon.alpha = 1;
			}
		}
	}
}
