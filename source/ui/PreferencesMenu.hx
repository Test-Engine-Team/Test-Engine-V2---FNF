package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import ui.AtlasText.AtlasFont;
import ui.TextMenuList.TextMenuItem;

class PreferencesMenu extends ui.OptionsState.Page
{
	public static var preferences:Map<String, Dynamic> = new Map();

	var items:TextMenuList;

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var camFollow:FlxObject;

	public function new()
	{
		super();

		menuCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		createPrefItem('Ghost Tapping', 'gt', true);
		createPrefItem('naughtyness', 'censor-naughty', true);
		createPrefItem('downscroll', 'downscroll', false);
		createPrefItem('flashing menu', 'flashing-menu', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', true);
		createPrefItem('Botplay', 'bot', false);
		createPrefItem('FPS Counter', 'fps-counter', true);
		createPrefItem('Auto Pause', 'auto-pause', false);
		createPrefItem('OG ui', 'old', false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 160;
		menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected)
		{
			camFollow.y = selected.y;
		});
	}

	public static function getPref(pref:String):Dynamic
	{
		return preferences.get(pref);
	}

	// easy shorthand?
	public static function setPref(pref:String, value:Dynamic):Void
	{
		preferences.set(pref, value);
	}

	public static function initPrefs():Void
	{
		if(FlxG.save.data.preferences != null)
			preferences = FlxG.save.data.preferences;

		preferenceCheck('gt', true);
		preferenceCheck('censor-naughty', true);
		preferenceCheck('downscroll', false);
		preferenceCheck('flashing-menu', true);
		preferenceCheck('camera-zoom', true);
		preferenceCheck('bot', false);
		preferenceCheck('fps-counter', true);
		preferenceCheck('auto-pause', false);
		preferenceCheck('old', false);
		preferenceCheck('master-volume', 1);

		FlxG.autoPause = getPref('auto-pause');
	}

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic):Void
	{
		items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.Bold, function()
		{
			preferenceCheck(prefString, prefValue);

			switch (Type.typeof(prefValue).getName())
			{
				case 'TBool':
					prefToggle(prefString);

				default:
					trace('swag');
			}
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				createCheckbox(prefString);

			default:
				trace('swag');
		}

		trace(Type.typeof(prefValue).getName());
	}

	function createCheckbox(prefString:String)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	/**
	 * Assumes that the preference has already been checked/set?
	 */
	private function prefToggle(prefName:String)
	{
		var daSwap:Bool = preferences.get(prefName);
		daSwap = !daSwap;
		preferences.set(prefName, daSwap);
		checkboxes[items.selectedIndex].daValue = daSwap;
		trace('toggled? ' + preferences.get(prefName));

		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();

		switch (prefName)
		{
			case 'fps-counter':
				Main.fpsCounter.visible = getPref('fps-counter');
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(daItem:TextMenuItem)
		{
			if (items.selectedItem == daItem)
				daItem.x = 150;
			else
				daItem.x = 120;
		});
	}

	private static function preferenceCheck(prefString:String, prefValue:Dynamic):Void
	{
		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();

		if (preferences.get(prefString) == null)
		{
			preferences.set(prefString, prefValue);
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + preferences.get(prefString));
		}
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		antialiasing = true;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		this.daValue = daValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (animation.curAnim.name)
		{
			case 'static':
				offset.set();
			case 'checked':
				offset.set(17, 70);
		}
	}

	function set_daValue(value:Bool):Bool
	{
		if (value)
			animation.play('checked', true);
		else
			animation.play('static');

		return value;
	}
}
