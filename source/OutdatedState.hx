package;

#if desktop

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import lime.app.Application;
import MainMenuState;

class OutdatedState extends MusicBeatState
{
    public static var newVer:String;
    var oldVer:String;

    public static var leftState:Bool = false;

    override function create()
    {
        oldVer = Application.current.meta.get('version');

        var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0x302D2D;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.scrollFactor.set(0, 0);
        add(menuBG);

        var outdatedTxt = new FlxText(0, 40, FlxG.width);
        outdatedTxt.text = "Test Engine is outdated!\nPlease Update the engine!\n\nYour Version: " + oldVer + "\nNew Version: " + newVer;
        outdatedTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        add(outdatedTxt);

        var updateTxt = new FlxText(-100, FlxG.height - 200, FlxG.width, "Press Enter to Update");
        updateTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        add(updateTxt);

        var leaveTxt = new FlxText(100, FlxG.height - 200, FlxG.width, "Press Escape to Ignore");
        leaveTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        add(leaveTxt);
    }

    override public function update(elapsed:Float)
    {
        if (controls.ACCEPT) {
            leftState = true;
            openURL("https://github.com/Test-Engine-Team/Test-Engine-V2---FNF/actions");
            FlxG.switchState(new MainMenuState());
        }
        if (controls.BACK) {
            leftState = true;
            FlxG.switchState(new MainMenuState());
        }
    }

    function openURL(url:String):Void
    {
        #if linux
		Sys.command('/usr/bin/xdg-open', [
			url,
			"&"
		]);
		#else
		FlxG.openURL(url);
		#end
    }
}
#end