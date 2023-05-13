package editors;

import flixel.FlxCamera;
import flixel.FlxSubState;
import editors.character.CharSelectSubstate;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
#if sys
import sys.FileSystem;
#end

using StringTools;

class ModShitSelect extends MusicBeatState
{
	var tabs = [{name: "Mods", label: 'Mods'}];

	var UI_box:FlxUITabMenu;

	var cam:FlxCamera;

	public static var modSelected:String;

	override public function create()
	{
		FlxG.mouse.enabled = true;
		FlxG.mouse.visible = true;

		cam = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);

		var magenta = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		magenta.screenCenter();
		magenta.color = 0xff434141;
		add(magenta);

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addModsCuzYez();
	}

	override public function update(elapesed:Float)
	{
		super.update(elapesed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());
	}

	#if sys
	var mods:Array<String> = FileSystem.readDirectory('./mods');
	#end

	function addModsCuzYez()
	{
		var modsTab:FlxUI = new FlxUI(null, UI_box);
		modsTab.name = 'Mods';
		UI_box.addGroup(modsTab);

		#if sys
		for (fucking in 0...mods.length)
		{
			var modsShit:FlxButton = new FlxButton(10, 20 * fucking, mods[fucking], function()
			{
				modSelected = mods[fucking];
				trace(modSelected);

				var sub = new CharSelectSubstate(0, 0);
				sub.cameras = [cam];
				openSubState(sub);
			});
			modsTab.add(modsShit);
		}
		#end
	}
}
